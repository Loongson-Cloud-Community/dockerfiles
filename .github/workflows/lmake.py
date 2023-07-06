#!/usr/bin/python3

"""
1. pip3 install GitPython
2. pip3 install ansible
"""

import os
import sys
from enum import Enum
import typing as t

# ansible
import ansible
from ansible import context
from ansible.module_utils.common.collections import ImmutableDict
from ansible.parsing.dataloader import DataLoader
from ansible.vars.manager import VariableManager
from ansible.inventory.manager import InventoryManager
from ansible.playbook.play import Play
from ansible.executor.task_queue_manager import TaskQueueManager
from ansible.plugins.callback import CallbackBase

import git

context.CLIARGS = ImmutableDict(
    connection='ssh', remote_user=None, listtags=None, listhosts=None, listtasks=None,
    module_path=None, verbosity=5, ask_sudo_pass=False, private_key_file=None,
    become=None, become_method=None, become_user=None,
    forks=10, check=False, diff=False, syntax=None, start_at_task=None,
)


class ResType(Enum):
    OK = 0
    FAILED = 1
    UNREACHABLE = 2


_res = {}


class ResultCallback(CallbackBase):

    def v2_runner_on_ok(self, result: 'ansible.executor.task_result.TaskResult'):
        _res["type"] = ResType.OK
        _res["stdout"] = result._result["stdout"]

    def v2_runner_on_failed(self, result, ignore_errors=False):
        _res["type"] = ResType.FAILED
        _res["stdout"] = result._result["stdout"]

    def v2_runner_on_unreachable(self, result):
        _res["type"] = ResType.UNREACHABLE


class AnsibleApi:

    def __init__(self):
        self.loader = DataLoader()
        self.result_callback = ResultCallback()
        self.passwords = dict()
        self.inventory = InventoryManager(loader=self.loader,
                                          sources=['/etc/ansible/inventory/hosts', '/etc/ansible/hosts'])
        self.variable_manager = VariableManager(loader=self.loader, inventory=self.inventory)

    def run_adhoc(self, name, hosts, tasks):
        play_source = dict(
            name=name,
            hosts=hosts,
            gather_facts='no',
            tasks=tasks
        )
        play = Play().load(play_source, variable_manager=self.variable_manager, loader=self.loader)
        tqm = None
        try:
            tqm = TaskQueueManager(
                inventory=self.inventory,
                variable_manager=self.variable_manager,
                loader=self.loader,
                passwords=self.passwords,
                stdout_callback=self.result_callback,
                run_tree=False,
            )
            tqm.run(play)  # most interesting data for a play is actually sent to the callback's methods
        finally:
            if tqm is not None:
                tqm.cleanup()


class GitApi:

    def get_head_changed_files(self, path: str) -> t.List[str]:
        files_str: str = git.Repo(path).git.diff('--name-only', 'HEAD^')
        return files_str.split('\n')


def get_build_dir_from_diff() -> str:
    files = GitApi().get_head_changed_files(os.getcwd())
    for file_ in files:
        strs = file_.split('/')
        if len(strs) >= 4:
            return "/".join(strs[:3])
    return ""


def run_task(cmd: str):
    a = AnsibleApi()
    host_list = ['la']
    build_dir = get_build_dir_from_diff()
    if len(build_dir) == 0:
        print("没有发生镜像修改")
        sys.exit(0)
    args = "chdir={chdir} make {cmd} -C {build_dir} 2>&1".format(chdir=os.getcwd(), cmd=cmd, build_dir=build_dir)
    print(args)
    task_list = [
        dict(action=dict(module='shell', args=args))
    ]
    a.run_adhoc(name="checkConnection", hosts=host_list, tasks=task_list)
    if _res["type"] == ResType.OK:
        print(_res["stdout"])
        sys.exit(0)
    elif _res["type"] == ResType.FAILED:
        print(_res["stdout"])
        sys.exit(1)
    elif _res["type"] == ResType.UNREACHABLE:
        print("构建机器网络中断")
        sys.exit(1)
    else:
        raise RuntimeError("Unknown error")


if __name__ == '__main__':
    if len(sys.argv) != 2:
        print("./lmake [image | push]")
    run_task(sys.argv[1])

