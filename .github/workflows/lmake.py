#!/usr/bin/python3

"""
1. pip3 install GitPython
2. pip3 install requests
3. pip3 install docker
"""
import datetime
import os
import re
import subprocess
import sys
import typing as t

import git
import peewee
import requests
import docker
import pandas
import json

harbor_username = ""
harbor_passwd = ""
github_auth = ""


# 配置
DB_PATH = "/docker/cidb/docker_image.db"
# 常量
STR_CR_SITE = "cr.loongnix.cn"
# 字符串
str_log_prefix = "/logs"
# 全局变量
docker_client = docker.APIClient()


class GitApi:

    def get_head_changed_files(self, path: str) -> t.List[str]:
        files_str: str = git.Repo(path).git.diff('--name-only', 'HEAD^')
        return files_str.split('\n')


class GithubApi:
    '''
    github官方api的的调用封装
    '''

    def __init__(self):

        self._headers = {
            "Accept": "application/vnd.github+json",
            "Authorization": github_auth,
            "X-GitHub-Api-Version": "2022-11-28"
        }

        self._proxies = {
            'http': os.environ["http_proxy"],
            'https': os.environ["https_proxy"],
        }

    def get_pr_files(self, pr_number) -> t.List[str]:
        """
        文档地址： https://docs.github.com/en/rest/pulls/pulls?apiVersion=2022-11-28#list-pull-requests-files
        从github的pr里面获取到文件变动的信息
        :param pr_number:
        :return:
        """
        url = "https://api.github.com/repos/Loongson-Cloud-Community/dockerfiles/pulls/{pr_number}/files".format(
            pr_number=pr_number)
        res = requests.get(url=url, headers=self._headers, proxies=self._proxies)
        if not res.ok:
            print("error: 没有从github获取到变动文件")
            print(res.content)
            sys.exit(1)

        res_ = set()
        for desc in res.json():
            strs = desc["filename"].split("/")
            if len(strs) >= 4:
                res_.add("/".join(strs[:3]))
        return [p for p in res_]

    def get_pr_info(self, pr_number) -> t.Dict:
        """
        文档地址： https://docs.github.com/en/rest/pulls/pulls?apiVersion=2022-11-28#get-a-pull-request
        获取到pull request本身的信息，并获取其中的comment_url的信息
        :param pr_number:
        :return:
        """
        url = "https://api.github.com/repos/Loongson-Cloud-Community/dockerfiles/pulls/{pr_number}".format(
            pr_number=pr_number)
        res = requests.get(url=url, headers=self._headers, proxies=self._proxies)
        if not res.ok:
            print("error: 没有获取到pr信息")
            sys.exit(1)

        return res.json()

    def comment_on_pr(self, comments_url, markdown_data):
        """
        :param comments_url: 从pull request信息中获取
        :param markdown_data:
        :return:
        """
        data = dict(body=markdown_data)
        res = requests.post(url=comments_url, headers=self._headers, proxies=self._proxies, json=data)
        if not res.ok:
            print("error: comment on pr failed")
            print(res.content)
            sys.exit(1)


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

    def log_dir(self) -> str:
        return "/logs" + "/" + self.build_dir()

    def log_path(self) -> str:
        return "/logs" + "/" + self.build_dir() + "/" + "build.log"

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

    def get_cr_names(self):
        pass


class DockerApi:

    def get_tags(self, sha_or_name: str) -> t.List[str]:
        return docker_client.inspect_image(sha_or_name)['RepoTags']


class HarborApi:

    def create_project(self, repo: Repo) -> bool:
        """
        通过api在harbor上创建项目
        :param repo:
        :return:
        """
        url = "http://harbor.loongnix.cn/api/v2.0/projects"
        auth = (harbor_username, harbor_passwd)
        project_data = {
            "project_name": repo.org_project,
            "metadata": {
                "public": "true"
            },
            "storage_limit": -1
        }

        headers = {
            "Content-Type": "application/json"
        }

        # 禁止使用代理，不然会访问到公网的harbor.loongnix.cn
        os.environ['NO_PROXY'] = 'harbor.loongnix.cn'
        response = requests.post(url, verify=False, headers=headers, auth=auth, json=project_data)

        if response.ok:
            return True
        else:
            print("error: harbor创建项目失败, 项目已经存在")
            print(response.content)
            return False

    def scan(self, repo: Repo):
        """
        通过api发起harbor上的镜像扫描
        :param repo:
        :return:
        """
        url = "http://harbor.loongnix.cn/api/v2.0/projects/{project_name}/repositories/{repo_name}/artifacts/{tag}/scan".format(
            project_name=repo.org_project, repo_name=repo.repo, tag=repo.version)
        os.environ['NO_PROXY'] = 'harbor.loongnix.cn'
        auth = (harbor_username, harbor_passwd)
        headers = {
            "Content-Type": "application/json"
        }
        response = requests.post(url, verify=False, headers=headers, auth=auth)
        if response.ok:
            print("成功发起镜像cve漏洞扫描")
        else:
            print("error: 镜像扫描发起失败")

    def get_project_id(self, repo: Repo) -> str:
        docker_client = docker.from_env()
        for image in docker_client.images():
            if image['RepoTags'] and repo.harbor_name() in image['RepoTags']:
                return image['Id']


class DockleApi:

    def scan(self, image: 'str') -> dict:
        """
        通过dockle扫描镜像, 输出的格式为dict
        :param image:
        :return:
        """
        child = subprocess.Popen(['dockle', '-f', 'json', image],
                                 stdout=subprocess.PIPE, stderr=subprocess.STDOUT)
        child.wait()
        print("扫描镜像: {}")
        json_str = child.stdout.read().decode()
        return json.loads(json_str)

    def scan2markdown(self, image: 'str') -> str:
        """
        以markdown形式输出警告级别
        :param image:
        :return:
        """
        m = self.scan(image)
        data = {
            "code": [],
            "level": [],
            "alerts": [],
        }
        for detail in m["details"]:
            data["code"].append(detail["code"])
            data["level"].append(detail["level"])
            data["alerts"].append(detail["alerts"][0])

        df = pandas.DataFrame(data=data)
        return df.to_markdown()

    def scan2json(self, image: 'str'):
        return self.scan(image)

# 数据库部分

db = peewee.SqliteDatabase(DB_PATH)


def _now() -> str:
    return datetime.datetime.now().strftime('%Y-%m-%d %H:%M:%S')


class RepoPO(peewee.Model):
    id = peewee.AutoField()
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

# 解析部分
class ImageParse:

    def __init__(self, short_sha: str):
        self._short_sha = short_sha

    def repo_tags(self) -> t.List[str]:
        if self._short_sha == "0":
            return ["scratch"]
        return docker_client.inspect_image(self._short_sha)["RepoTags"]

    def first_cr_name(self) -> t.Optional[str]:
        for s in docker_client.inspect_image(self._short_sha)["RepoTags"]:
            if STR_CR_SITE in s:
                return s
        return None

    def first_name(self) -> str:
        if self.short_sha() == "0":
            return "scratch"
        for s in docker_client.inspect_image(self._short_sha)["RepoTags"]:
            return s
        return ""

    def fit_name(self) -> str:
        if self.is_scratch():
            return "scratch"
        # 如果存在仓库优先返回带仓库信息的名称
        for s in docker_client.inspect_image(self._short_sha)["RepoTags"]:
            if STR_CR_SITE in s:
                return s
        return self.first_name()

    def is_scratch(self) -> bool:
        return "0" == self._short_sha

    def short_sha(self) -> str:
        return self._short_sha

    def __eq__(self, other):
        return self._short_sha == other.short_sha()

    def __hash__(self):
        return hash(self._short_sha)


def scratch_image():
    return ImageParse("0")


class DependencyVO:

    def __init__(self):
        self.target: t.Optional[ImageParse] = None
        self.dependencies: t.Set[ImageParse] = set()

    def __str__(self):
        target_cr_name = self.target.first_name()
        dependencies = ",".join([dep.first_name() for dep in self.dependencies])
        return "DependencyVO[target:{target}, dependencies:{dependencies}]".format(target=target_cr_name,
                                                                                   dependencies=dependencies)

    def get_dependency_pair(self) -> t.List[t.Tuple[str, str]]:
        res = []
        print(len(self.dependencies))
        for dep in self.dependencies:
            print("short_sha:", dep.short_sha())
            res.append((self.target.fit_name(), dep.fit_name()))
        return res


class Parser:

    def __init__(self, log_path: str):
        with open(log_path, "r") as f:
            self._lines = f.readlines()
        #
        self._dependencies: t.List[DependencyVO] = []
        self._dependency = DependencyVO()
        self._cur_index = 0

    def parse(self):
        first_dep = True
        while self._cur_index < len(self._lines):

            str_ = self._lines[self._cur_index]
            if re.match(r'^Sending build context to Docker daemon .*?\n', str_):
                if first_dep:
                    first_dep = False
                else:
                    self.reset()
            elif re.match(r'Step \d+/\d+ : FROM (.*?)\n', str_):
                self.parse_from()
            elif re.match(r'Successfully built (\S+)\n', str_):
                self.parse_success_build(str_)
            self._cur_index += 1

        self.reset()

    def _from_match_scratch(self) -> bool:
        re_list = [
            r'Step \d+/\d+ : FROM (.*?)\n',
            r'Step \d+/\d+ : FROM (.*?) AS .*?\n',
            r'Step \d+/\d+ : FROM (.*?) as .*?\n'
        ]
        for re_str in re_list:
            res = re.findall(re_str, self._lines[self._cur_index])
            if len(res) > 0 and (res[0] == "scratch"):
                return True
        return False

    def parse_from(self):
        if self._from_match_scratch():
            self._dependency.dependencies.add(scratch_image())
        else:
            while True:
                str_ = self._lines[self._cur_index]
                res = re.findall(r' ---> (\S+)\n', str_)
                if len(res) > 0:
                    self._dependency.dependencies.add(ImageParse(res[0]))
                    break
                self._cur_index += 1

        while not re.match(r'^Step \d+/\d+ :(.*?)\n', self._lines[self._cur_index + 1]):
            self._cur_index += 1

    def parse_success_build(self, s: str):
        res = re.findall(r'Successfully built (\S+)\n', s)
        self._dependency.target = ImageParse(res[0])

    def reset(self):
        if self._dependency.target:
            self._dependencies.append(self._dependency)
        self._dependency = DependencyVO()

    def dependencies(self) -> t.List[DependencyVO]:
        return self._dependencies


class BuildOperation:

    def _repos(self) -> t.List[Repo]:
        # 1. 从github获取镜像变动的目录
        build_dirs = GithubApi().get_pr_files(os.environ["PR_NUMBER"])
        return [Repo.from_dir(build_dir) for build_dir in build_dirs]

    def _build(self, repo: Repo):
        # 需要同时在日志文件和终端进行日志输出
        # 1. 计算出日志的路径
        log_dir = repo.log_dir()
        log_path = repo.log_path()
        os.makedirs(log_dir, exist_ok=True)
        # 2. 执行构建命令
        with open(log_path, 'w') as f:
            # 运行命令并同时输出到文件和终端
            process = subprocess.Popen(['make', 'image', '-C', repo.build_dir()],
                                       stdout=subprocess.PIPE,
                                       stderr=subprocess.PIPE,
                                       )
            while True:
                output = process.stdout.readline().decode()
                if output == '' and process.poll() is not None:
                    break
                if output:
                    sys.stdout.write(output)
                    f.write(output)

        if process.returncode != 0:
            sys.exit(process.returncode)

    def _parse_log(self, repo: Repo):
        '''
        从构建日志中解析依赖关系存储到数据库当中
        '''
        repo_obj = RepoPO.select().where(RepoPO.name==repo.cr_name())[0]
        # 日志解析部分
        parser = Parser(repo.log_path())
        parser.parse()
        with db.atomic() as tx:
            DependencyPO.delete().where(DependencyPO.repo_name == repo.cr_name()).execute()
            for dependency in parser.dependencies():
                for t, d in dependency.get_dependency_pair():
                    if len(d) == 0 or len(t) == 0:
                        continue
                    DependencyPO.create(
                        repo_id=repo_obj.id,
                        repo_name=repo.cr_name(),
                        image=t,
                        dependency=d,
                        description=""
                    )

    def _save_build_info(self, repo: Repo):
        repo_obj = RepoPO.get_or_none(name=repo.cr_name())
        if repo_obj is None:
            repo_obj = RepoPO.create(
                name=repo.cr_name()
            )
        repo_obj.build_success = True
        repo.is_build = True
        repo_obj.save()

    def _check_image(self, repo: Repo):
        dockle = DockleApi()
        # dependencies = DependencyPO.select().where(DependencyPO.repo_name==repo.cr_name())
        dependencies = DependencyPO.select(DependencyPO.image).distinct().where(DependencyPO.repo_name==repo.cr_name())
        github_api = GithubApi()
        comment_url = self._get_comment_url()
        for dependency in dependencies:
            # 镜像名称必须包含“cr.loongnix.cn”
            if STR_CR_SITE in dependency.image:
                md_table = dockle.scan2markdown(dependency.image)
                res = '- ' + dependency.image + '\n\n' + md_table
                github_api.comment_on_pr(comment_url, res)

    def _get_comment_url(self) -> str:
        # 1. 检查是否为pr
        if not ("PR_NUMBER" in os.environ and len(os.environ["PR_NUMBER"]) > 0):
            sys.exit(0)
        pr_number = os.environ["PR_NUMBER"]
        # 2. 通过api检查pr的状态
        github_api = GithubApi()
        pr_info = github_api.get_pr_info(pr_number)
        # 3. 判断当前的pr是否已经关闭
        if pr_info["closed_at"] or pr_info["merged_at"]:
            sys.exit(0)
        comment_url = pr_info["_links"]["comments"]["href"]
        return comment_url

    def _update_warning(self, image_name: str, cur_repo: Repo):
        # repo_name 表示项目， image表示具体的镜像
        # select distinct reoi_name from dependency where dependency='cr.loongnix.cn/library/golang:1.19' and repo_name != 'cr.loongnix.cn/library/golang:1.19'
        dependencies = DependencyPO.select(DependencyPO.repo_name).distinct().where(
            (DependencyPO.dependency==image_name) & (DependencyPO.repo_name!=cur_repo.cr_name()))
        repo_names = [dependency.repo_name for dependency in dependencies]
        if len(repo_names) == 0:
            return
        users = "\n@zhaixiaojuan @znley \n"
        md_str = "- " + image_name + "本次镜像更新会涉及如下项目" + ": \n"
        content = "\n```\n" + json.dumps(repo_names, indent=2) + "\n```\n"
        md_str = md_str + content + users
        # github api
        github_api = GithubApi()
        comment_url = self._get_comment_url()
        github_api.comment_on_pr(comment_url, md_str)

    def _update_warnings(self, repo: Repo):
        # 找出生产的镜像
        # select distinct image from dependency where repo_name="cr.loongnix.cn/calico/go-build:0.73"
        dependencies = DependencyPO.select(DependencyPO.image).distinct().where(DependencyPO.repo_name == repo.cr_name())
        docker_api = DockerApi()
        for dependency in dependencies:
            for image_name in docker_api.get_tags(dependency.image):
                if STR_CR_SITE in image_name:
                    self._update_warning(image_name, repo)

    def run_build(self, repo: Repo):
        self._build(repo)
        self._save_build_info(repo)
        self._parse_log(repo)
        self._check_image(repo)
        self._update_warnings(repo)

    def run_multi_build(self):
        for repo in self._repos():
            self.run_build(repo)


class MultiUpdate:

    def repos_to_update(self, repo: Repo) -> t.List[Repo]:
        # 1. 获取构建的项目，产生的镜像， 一个或者多个
        dependencies_for_image = DependencyPO.select(DependencyPO.image).distinct().where(DependencyPO.repo_name == repo.cr_name())
        # 2. 获取镜像所有的tag，这里获取的tag需要包含"cr.loongnix.cn"
        res = []
        for dependency in dependencies_for_image:
            # res = res + self._all_loongnix_tag(dependency.image)
            tags = self._all_loongnix_tag(dependency.image)
            res = res + self._get_images_by_tags(tags, repo)
        return [Repo.from_cr_name(name) for name in res]

    def _all_loongnix_tag(self, tag: str) -> t.List[str]:
        docker_api = DockerApi()
        res = []
        for tag in docker_api.get_tags(tag):
            if STR_CR_SITE in tag:
                res.append(tag)
        return res

    def _get_images_by_tags(self, tags: t.List[str], cur_repo: Repo) -> t.List[str]:
        '''
        一个镜像会存在多个tag, 比如"cr.loongnix.cn/library/golang:1.19"和"cr.loongnix.cn/library/golang:1.19-buster"
        '''
        res = []
        for tag in tags:
            res = res + self._get_image_by_dependency(tag, cur_repo)
        return res

    def _get_image_by_dependency(self, image_name: str, cur_repo: Repo) -> t.List[str]:
        # 查询依赖"image_name"的项目
        dependencies = DependencyPO.select(DependencyPO.repo_name).distinct().where(
            (DependencyPO.dependency==image_name) & (DependencyPO.repo_name!=cur_repo.cr_name()))
        res = []
        for dependency in dependencies:
            if STR_CR_SITE in dependency.repo_name:
                res.append(dependency.repo_name)
        return res

    def _image_build(self, repo: Repo):
        process = subprocess.run(["make", "image", "-C", repo.build_dir()])
        if process.returncode != 0:
            print("{name}升级失败".format(name=repo.cr_name()))
        else:
            print("{name}升级成功".format(name=repo.cr_name()))

    def _image_push(self, repo):
        subprocess.run(["make", "push", "-C", repo.build_dir()])

    def run(self, repo):
        for repo_ in self.repos_to_update(repo):
            self._image_build(repo_)
            self._image_push(repo_)


class MergeOperation:

    def _repos(self) -> t.List[Repo]:
        # 1. 从github获取镜像变动的目录
        build_dirs = GithubApi().get_pr_files(os.environ["PR_NUMBER"])
        return [Repo.from_dir(build_dir) for build_dir in build_dirs]

    def _push(self, repo: Repo):
        process = subprocess.run(["make", "push", "-C", repo.build_dir()])
        if process.returncode != 0:
            sys.exit(process.returncode)

    def _cve_scan(self, repo: Repo):
        # 1. 创建project
        harbor_api = HarborApi()
        harbor_api.create_project(repo)
        # 2. 修改标签 && 推送到harbor
        cp = subprocess.run(["docker", "tag", repo.cr_name(), repo.harbor_name()])
        if cp.returncode != 0:
            sys.exit(cp.returncode)
        cp = subprocess.run(["docker", "push", repo.harbor_name()])
        if cp.returncode != 0:
            sys.exit(cp.returncode)
        # 3. 进行harbor镜像扫描
        harbor_api.scan(repo)

    def _cve_scan_all(self, repo: Repo):
        # 1. 从数据库当中获取所有的构建成功的镜像
        dependencies = DependencyPO.select().where(DependencyPO.repo_name==repo.cr_name())
        for dependency in dependencies:
            if STR_CR_SITE in dependency.image:
                self._cve_scan(Repo.from_cr_name(dependency.image))

    def run_push(self, repo: Repo):
        self._push(repo)
        self._cve_scan(repo)

    def run_multi_push(self):
        for repo in self._repos():
            self.run_push(repo)
            # 触发级联更新
            multi_update = MultiUpdate()
            multi_update.run(repo)


if __name__ == '__main__':
    if sys.argv[1] == "image":
        build_operation = BuildOperation()
        build_operation.run_multi_build()
    elif sys.argv[1] == "merge":
        merge_operation = MergeOperation()
        merge_operation.run_multi_push()
    else:
        print("不支持该命令")
        sys.exit(1)
