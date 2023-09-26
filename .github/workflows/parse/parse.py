import re
import typing as t
import datetime
import subprocess
import threading
from concurrent import futures

# 第三方库
import peewee


class Repo:
    """
    描述单个docker镜像的信息

    Attributes:
        :org_project 镜像的组织名称，比如library
        :repo 项目名称，比如nginx
        :version 版本信息，比如1.21
    """

    def __init__(self, project, repo, version):
        self.org_project = project
        self.repo = repo
        self.version = version

    def harbor_name(self) -> str:
        return "harbor.loongnix.cn/{org}/{repo}:{version}".format(org=self.org_project, repo=self.repo,
                                                                  version=self.version)

    def cr_name(self) -> str:
        return "cr.loongnix.cn/{org}/{repo}:{version}".format(org=self.org_project, repo=self.repo,
                                                              version=self.version)

    def build_dir(self) -> str:
        return "{org}/{repo}/{version}".format(org=self.org_project, repo=self.repo, version=self.version)

    @staticmethod
    def from_dir(build_dir: 'str'):
        return Repo(*build_dir.split('/'))

    @staticmethod
    def from_cr_name(cr_name: 'str'):
        '''
        从镜像名称来构建Repo对象
        :param cr_name: cr.loongnix.cn/library/golang:1.19-alpine
        :return:
        '''
        cr_name = cr_name.strip()
        res = re.findall(r'cr.loongnix.cn/(.*?)/(.*?):(.*?)$', cr_name)
        if len(res[0]) != 3:
            raise ValueError("cr_name's format must like 'cr.loongnix.cn/library/golang:1.19-alpine'")
        return Repo(*res[0])


db = peewee.SqliteDatabase('docker_image.db')

##################################工具函数############################################


def _now():
    return datetime.datetime.now().strftime('%Y-%m-%d %H:%M:%S')
##################################工具函数############################################


class RepoPO(peewee.Model):
    name = peewee.CharField(unique=True, help_text="镜像名称")
    build_success = peewee.BooleanField(default=False)
    create_at = peewee.DateTimeField(formats='%Y-%m-%d %H:%M:%S', default=_now)
    update_at = peewee.DateTimeField(formats='%Y-%m-%d %H:%M:%S', default=_now)
    is_build = peewee.BooleanField(default=False)

    class Meta:
        database = db
        db_table = "repo"


RepoPO.create_table()


class DependencyPO(peewee.Model):

    repo_id = peewee.CharField(index=True)
    repo_name = peewee.CharField(index=True)
    image = peewee.CharField(index=True)
    dependency = peewee.CharField(index=True)
    description = peewee.CharField()

    class Meta:
        database = db
        db_table = "dependency"


DependencyPO.create_table()


class ImageDepVO:
    '''
    对于单条的依赖关系进行可视化输出
    '''

    def __init__(self):
        self.dep = ''
        self.build_deps = []
        self.target = ''

    def __str__(self):
        dep_str = self.dep
        build_deps_str = ",".join(self.build_deps)
        target_str = self.target
        res = 'target:{target}, dep:{dep}, build_deps: [{build_deps}]'.format(target=target_str, dep=dep_str,
                                                                              build_deps=build_deps_str)
        return 'ImageDepVO{' + res + '}'


def image_dep_vo_from_dict(data: t.Dict) -> ImageDepVO:
    '''
    ImageDepVO 类的工厂函数
    :param data:
    :return:
    '''
    dep = ImageDepVO()
    dep.dep = data["deps"][0]
    dep.build_deps = data["builders"]
    dep.target = data["targets"][0]

    return dep


class Parser:
    '''
    对于构建日志的内容进行解析，最终的结果存储在_res之中，单条依赖关系的数据结构为_single_res
    '''
    def __init__(self, log_path):
        self._log_path = log_path
        self._res = []
        self._single_res = {
            "deps": [],
            "builders": [],
            "targets": [],
            "envs": {},
        }
        # 解析部分变量
        self._cur_index = 0
        f = open(self._log_path, "r")
        self._lines = f.readlines()
        f.close()
        self._docker_index = -1

    def parse(self):
        for i, str_ in enumerate(self._lines):
            self._cur_index = i

            # "Sending build context to Docker daemon" 代表了上个镜像的相关信息已经完成解析
            if re.match(r'^Sending build context to Docker daemon .*?\n', str_):
                if self._docker_index >= 0:
                    self.reset()
                self._docker_index += 1
            # 解析
            if re.match(r'^Sending build context to Docker daemon .*?\n', str_):
                self.parse_docker_pull_cmd()
            elif re.match(r'Step \d+/\d+ : ARG (\S+)\n', str_):
                self.parse_arg(str_)
            elif re.match(r'Step \d+/\d+ : FROM (.*?)\n', str_):
                self.parse_from(str_)
            elif re.match(r'Successfully tagged (.*?)\n', str_) or re.match(r'Successfully tagged (.*?)$', str_):
            # elif re.match(r'Successfully built (.*?)\n', str_)
                # todo 组合解析 Successfully built 07f512dd3680
                self.parse_success(str_)
        # 添加最后一个镜像信息
        self.reset()

    def parse_docker_pull_cmd(self):
        s = self._lines[self._cur_index - 1]
        cur = self._cur_index - 2
        while len(self._lines[cur].strip()) and self._lines[cur].strip()[-1] == '\\':
            s = self._lines[cur] + s
            cur -= 1

        envs = self._single_res["envs"]
        kvs = re.findall(r'--build-arg (.*?=.*?) ', s)
        for kv in kvs:
            kv_ = kv.strip()
            k, v = kv_.split('=')
            envs[k] = v

    def parse_arg(self, s: str):
        envs = self._single_res["envs"]
        if '=' not in s:
            return
        kv = re.findall(r'Step \d+/\d+ : ARG (\S+)\n', s)[0]
        k, v = kv.strip().split('=')
        if k not in envs:
            envs[k] = v

    def parse_from(self, s: str):
        # 1. 变量替换
        envs = self._single_res["envs"]
        for k, v in envs.items():
            var_ = "$" + k
            if var_ in s:
                s = s.replace(var_, v)

            var_curly_brackets = "${" + k + "}"
            if var_curly_brackets in s:
                s = s.replace(var_curly_brackets, v)

        # 2. 提取 from ... as 形式
        builders = self._single_res["builders"]
        builder = re.findall(r'Step \d+/\d+ : FROM (\S+) as (.*?)\n', s)
        if builder:
            builders.append(builder[0][0])
            return

        # 3. 提取 from ...
        deps = self._single_res["deps"]
        dep = re.findall(r'Step \d+/\d+ : FROM (\S+)\n', s)
        if dep:
            deps.append(dep[0])
            return

    def parse_success(self, s: str):
        targets = self._single_res["targets"]
        target = re.findall(r'Successfully tagged (.*?)\n', s) or re.findall(r'Successfully tagged (.*?)$', s)
        if target:
            targets.append(target[0])

    def reset(self):
        if len(self._single_res["targets"]) != 0:
            # todo 添加更多处理逻辑，校验cr.loongnix.cn, 只存储带版本信息的， 后续改为class
            image_name_res = ''
            for image_name in self._single_res["targets"]:
                if ('cr.loongnix.cn' in image_name) and ('latest' not in image_name_res):
                    image_name_res = image_name
                    break

            if len(image_name_res) == 0:
                print(self._single_res)

            if len(image_name_res) != 0:
                self._single_res['targets'] = [image_name_res]
                self._res.append(self._single_res)

        self._single_res = {
            "deps": [],
            "builders": [],
            "targets": [],
            "envs": {},
        }

    def res(self):
        return self._res


class DepInit:

    """
    这个类是一个工具类主要用来对于，仓库中已经有的Repo进行批量构建以及扫描
    """

    def __init__(self):
        '''
        :_lock: 因为sqllite数据库不支持多线程读写： https://www.cnblogs.com/Gaimo/p/15709092.html
        '''
        self._lock = threading.Lock()

    def scan_dep_from_dockefiles(self) -> t.List[Repo]:
        '''
        负责将所有的镜像信息写入返回值当中
        :return:
        '''
        child = subprocess.Popen(['find', './', '-name', 'Makefile'],
                                 stdout=subprocess.PIPE,
                                 stderr=subprocess.STDOUT)
        child.wait()
        res = child.stdout.read().decode()
        res_list = res.split('\n')
        repos = []
        for name in res_list:
            if len(name) == 0:
                continue
            # 消除开头的"./"和结尾的“/Makefile”
            relative_path = name[2:-9]
            # 目录层级校验， 比如： "library/nginx/1.21"
            if len(relative_path.split('/')) != 3:
                continue
            repo = Repo.from_dir(relative_path)
            repos.append(repo)
        return repos

    def generate_log(self, repo: Repo):
        # 1. 日志路径
        log_path = "/logs/" + repo.build_dir() + "/build.log"
        log_dir = "/logs/" + repo.build_dir()
        subprocess.run(["mkdir", "-p", log_dir])
        # 2. 执行构建命令
        with open(log_path, "w") as f:
            cp = subprocess.run(["make", "image", "-C", repo.build_dir()], stdout=f, stderr=f)
        build_success = False
        if cp.returncode == 0:
            build_success = True
        # 3. 构造初始数据， 写入数据库
        with self._lock:
            images = RepoPO.select().where(RepoPO.name == repo.cr_name())
            if len(images) != 0:
                image = images[0]
            else:
                image = RepoPO.create(
                    name=repo.cr_name(),
                    build_success=build_success,
                    is_build=False,
                )
            image.build_success = build_success
            image.is_build = True
            image.save()

    # 构造初始化部分
    def start_build_at(self, start_index=0):
        repos = self.scan_dep_from_dockefiles()
        for i in range(start_index, len(repos)):
            print("正在进行构建的是[{cur}/{total}], {repo_name}".format(cur=i,
                                                                total=len(repos) - 1,
                                                                repo_name=repos[i].cr_name()))
            self.generate_log(repos[i])

    def concurrent_build(self):
        repos = self.scan_dep_from_dockefiles()
        # 直接从数据库扫描
        with futures.ThreadPoolExecutor(max_workers=16) as executor:
            for repo in repos:
                # 这里的 "=="不是字面含义，是重载后作为表达式传递给数据库
                if RepoPO.select().where(RepoPO.name == repo.cr_name(), RepoPO.is_build == True):
                    print("{name} 已经构建过".format(name=repo.cr_name()))
                    continue
                print("正在构建{name}".format(name=repo.cr_name()))
                executor.submit(self.generate_log, repo)

    def scan_log(self, repo: Repo):
        """
        解析指定的Repo的日志，存储依赖关系
        :param repo:
        :return:
        """
        # 1. 日志路径
        log_path = "/logs/" + repo.build_dir() + "/build.log"
        # 2. parser
        parser = Parser(log_path)
        parser.parse()
        # 3. { "deps": [], "builders": [], "targets": [], "envs": {}, }
        dep_info_ = None
        for dep_info in parser._res:
            if repo.cr_name() in dep_info["targets"]:
                dep_info_ = dep_info

        if dep_info_ is None:
            return

        if len(dep_info_["deps"]) == 0:
            return
        # 4. 修改镜像依赖关系
        # 4.1 获取repo的name和id, todo 补充校验逻辑
        with db.atomic() as tx:
            repo_po_obj: RepoPO = RepoPO.select().where(RepoPO.name == repo.cr_name())[0]
            DependencyPO.delete().where(DependencyPO.repo_name == repo_po_obj.name).execute()
            # 根据扫描结果创建依赖关系
            deps = dep_info_["deps"] + dep_info_["builders"]
            target = dep_info_["targets"][0].strip()
            for dep in deps:
                dependency_obj = DependencyPO.create(
                    repo_id=repo_po_obj.id,
                    repo_name=repo_po_obj.name,
                    image=target,
                    dependency=dep,
                    description=''
                )
                dependency_obj.save()

    def scan_all_image_name(self):
        repos = self.scan_dep_from_dockefiles()
        for i in range(len(repos)):
            if RepoPO.select().where(RepoPO.name == repos[i].cr_name()):
                continue
            image = RepoPO.create(
                name=repos[i].cr_name(),
                build_success=False,
                is_build=False,
            )
            image.save()

    def scan_all_dependency(self):
        repos = RepoPO.select().where(RepoPO.build_success==True)
        for i in range(len(repos)):
            print("扫描进度：{index_}/{len_}, {name}".format(index_=i+1, len_=len(repos), name=repos[i].name))
            self.scan_log(Repo.from_cr_name(repos[i].name))

