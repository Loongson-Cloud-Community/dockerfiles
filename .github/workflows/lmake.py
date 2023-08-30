#!/usr/bin/python3

"""
1. pip3 install GitPython
2. pip3 install requests
"""

import os
import subprocess
import sys
# from enum import Enum
import typing as t


import git
import requests


class GitApi:

    def get_head_changed_files(self, path: str) -> t.List[str]:
        files_str: str = git.Repo(path).git.diff('--name-only', 'HEAD^')
        return files_str.split('\n')


class GithubApi:
    def __init__(self):

        self._headers = {
            "Accept": "application/vnd.github+json",
            "Authorization": "Bearer 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",
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
            print("error: 没有获取到变动文件")
            sys.exit(1)

        res_ = set()
        for desc in res.json():
            strs = desc["filename"].split("/")
            if len(strs) >= 4:
                res_.add("/".join(strs[:3]))
        return [p for p in res_]


def get_build_dir_from_diff() -> t.List[str]:
    files = GitApi().get_head_changed_files(os.getcwd())
    res = set()
    for file_ in files:
        strs = file_.split('/')
        if len(strs) >= 4:
            res.add("/".join(strs[:3]))
    return [p for p in res]


# 这里需要可以返回多个
# def get_build_dir_or_exit() -> str:
#     build_dirs = get_build_dir_from_diff()
#     if len(build_dir) == 0:
#         print("没有发生镜像修改")
#         sys.exit(0)
#     return build_dir


# def dockerfile_lint():
#     build_dir = get_build_dir_or_exit()
#     dockerfile = "{dir}/Dockerfile".format(dir=build_dir)
#     if os.path.exists(dockerfile):
#         cp = subprocess.run(["hadolint", dockerfile])
#         sys.exit(cp.returncode)
#     print("Dockerfile 不存在")
#     sys.exit(0)


def run_task_by_host(cmd: str, build_dir):
    cp = subprocess.run(["make", cmd, "-C", build_dir])
    if cp.returncode != 0:
        sys.exit(cp.returncode)


def run_tasks_by_host(cmd: str):
    build_dirs = get_build_dir_from_diff()
    if "PR_NUMBER" in os.environ and len(os.environ["PR_NUMBER"]) > 0:
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
    # if sys.argv[1] == "lint":
    #     dockerfile_lint()
    # else:
    #     run_tasks_by_host(sys.argv[1])

