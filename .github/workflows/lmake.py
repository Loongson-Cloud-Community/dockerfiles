#!/usr/bin/python3

"""
1. pip3 install GitPython
2. pip3 install requests
3. pip3 install docker-py
"""

import os
import subprocess
import sys
import typing as t


import git
import requests
import docker
import pandas
import json


harbor_username = ""
harbor_passwd = ""
github_auth = ""


class GitApi:

    def get_head_changed_files(self, path: str) -> t.List[str]:
        files_str: str = git.Repo(path).git.diff('--name-only', 'HEAD^')
        return files_str.split('\n')


class GithubApi:
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
        url = "https://api.github.com/repos/Loongson-Cloud-Community/dockerfiles/pulls/{pr_number}/files".format(pr_number=pr_number)
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
        url = "https://api.github.com/repos/Loongson-Cloud-Community/dockerfiles/pulls/{pr_number}".format(pr_number=pr_number)
        res = requests.get(url=url, headers=self._headers, proxies=self._proxies)
        if not res.ok:
            print("error: 没有获取到pr信息")
            sys.exit(1)

        return res.json()

    def comment_on_pr(self, comments_url, markdown_data):
        data = dict(body=markdown_data)
        res = requests.post(url=comments_url, headers=self._headers, proxies=self._proxies, json=data)
        if not res.ok:
            print("error: comment on pr failed")
            print(res.content)
            sys.exit(1)


class Repo:

    def __init__(self, project, repo, version):
        self.org_project = project
        self.repo = repo
        self.version = version

    def harbor_name(self) -> str:
        return "harbor.loongnix.cn/{org}/{repo}:{version}".format(org=self.org_project, repo=self.repo, version=self.version)

    def cr_name(self) -> str:
        return "cr.loongnix.cn/{org}/{repo}:{version}".format(org=self.org_project, repo=self.repo, version=self.version)

    def build_dir(self) -> str:
        return "{org}/{repo}/{version}".format(org=self.org_project, repo=self.repo, version=self.version)

    @staticmethod
    def from_dir(build_dir: 'str'):
        return Repo(*build_dir.split('/'))


class HarborApi:

    def __init__(self):
        pass

    def create_project(self, repo: Repo) -> bool:
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

        os.environ['NO_PROXY'] = 'harbor.loongnix.cn'
        response = requests.post(url, verify=False, headers=headers, auth=auth, json=project_data)

        if response.ok:
            return True
        else:
            print("error: harbor创建项目失败, 项目已经存在")
            print(response.content)
            return False

    def scan(self, repo: Repo):
        url = "http://harbor.loongnix.cn/api/v2.0/projects/{project_name}/repositories/{repo_name}/artifacts/{tag}/scan".format(project_name=repo.org_project, repo_name=repo.repo, tag=repo.version)
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

    def __init__(self):
        pass

    def scan(self, image: 'str'):
        child = subprocess.Popen(['dockle', '-f', 'json', image],
                                 stdout=subprocess.PIPE, stderr=subprocess.STDOUT)
        child.wait()
        json_str = child.stdout.read().decode()
        return json.loads(json_str)

    def scan2markdown(self, image: 'str'):

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
        # print(df.to_markdown())
        return df.to_markdown()

    def scan2json(self, image: 'str'):
        return self.scan(image)


def get_build_dir_from_diff() -> t.List[str]:
    files = GitApi().get_head_changed_files(os.getcwd())
    res = set()
    for file_ in files:
        strs = file_.split('/')
        if len(strs) >= 4:
            res.add("/".join(strs[:3]))
    return [p for p in res]


def push_hook(repo: Repo):
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


def build_hook(repo: Repo):
    # 1. 检查是否为pr
    if not ("PR_NUMBER" in os.environ and len(os.environ["PR_NUMBER"]) > 0):
        return
    pr_number = os.environ["PR_NUMBER"]
    # 2. 通过api检查pr的状态
    github_api = GithubApi()
    pr_info = github_api.get_pr_info(pr_number)
    if pr_info["closed_at"] or pr_info["merged_at"]:         # 验证一下
        return
    comment_url = pr_info["_links"]["comments"]["href"]
    # 3. dockle做层扫描
    dockle_api = DockleApi()
    md_table = dockle_api.scan2markdown(repo.cr_name())
    # 4. 输出m扫描markdown到pr
    #github_api.comment_on_pr(comment_url, md_table)
    content = '- ' + repo.cr_name() + '\n\n' + md_table
    github_api.comment_on_pr(comment_url, content)


# 在push操作上做hook， 添加build hook
def run_task_by_host(cmd: str, build_dir: str):
    cp = subprocess.run(["make", cmd, "-C", build_dir])
    if cp.returncode != 0:
        sys.exit(cp.returncode)
    repo = Repo.from_dir(build_dir)
    if cmd == "image":
        build_hook(repo)
    if cmd == "push":
        push_hook(repo)


def run_tasks_by_host(cmd: str):
    build_dirs = get_build_dir_from_diff()
    if "PR_NUMBER" in os.environ and len(os.environ["PR_NUMBER"]) > 0:
        print("当前task is in pull request")
        build_dirs = GithubApi().get_pr_files(os.environ["PR_NUMBER"])
    if len(build_dirs) == 0:
        print("没有发生镜像修改")
        sys.exit(0)

    print("发生镜像变更的目录如下：", build_dirs)
    for build_dir in build_dirs:
        run_task_by_host(cmd, build_dir)


if __name__ == '__main__':
    if len(sys.argv) != 2:
        print("./lmake [image | push | lint]")
    run_tasks_by_host(sys.argv[1])
