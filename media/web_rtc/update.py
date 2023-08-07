#!/usr/bin/env python3

import argparse
import os

updatedir = [
    'src/build',
    'src/tools',
    'src/third_party',
    'src/'
]

replace = (
    ('src/third_party/', 'llvm-build'),
    ('src/third_party/', 'android_ndk'),
    ('src/third_party/android_sdk/public/build-tools/', '31.0.0'),
    ('src/third_party/android_build_tools/', 'aapt2'),
    ('src/third_party/jdk/', 'current'),
    ('src/third_party/jdk/extras/', 'java_8'),
)

def pop_file():
    root_dir = os.getcwd()
    for dir in updatedir:
        os.chdir(dir)
        os.system("pwd")
        os.system("git stash pop")
        os.chdir(root_dir)


def stash_file():
    root_dir = os.getcwd()
    for dir in updatedir:
        os.chdir(dir)
        os.system("pwd")
        os.system("git add .")
        os.system("git stash save mac_build")
        os.chdir(root_dir)


def pop_tools(dirs):
    for item in dirs:
        dir = item[0]
        name = item[1]
        path = dir + name
        stash_path = f"{os.getcwd()}/stash/{name}"
        backup_path = f"{os.getcwd()}/backup/"
        if os.path.exists(path):
            # 替换是以软链接的形式添加的，如果是软链接就跳过。
            if os.path.islink(path):
                print(f"{path} is replaced, skip.")
                continue
            else:
                print(f"move {path} to {backup_path}")
                os.system(f"mv {path} {backup_path}")
        else:
            print(f"{path} is not exist!")
        print(f"link {path} -> {stash_path}")
        os.system(f"ln -s {stash_path} {path}")


def stash_tools(dirs):
    for item in dirs:
        dir = item[0]
        name = item[1]
        path = dir + name
        backup_path = f"{os.getcwd()}/backup/{name}"
        if os.path.exists(path):
            if os.path.islink(path):
                print(f"delete link {path}")
                os.remove(path)
            else:
                print(f"{path} is restored, skip.")
                continue;
        print(f"move  {backup_path} to {dir}")
        os.system(f"mv {backup_path} {dir}")


def main():
    parser = argparse.ArgumentParser()
    version_group = parser.add_mutually_exclusive_group()
    version_group.add_argument('--stash',
                               action='store_true',
                               help='Save the change of self update.')
    version_group.add_argument('--pop',
                               action='store_true',
                               help='Pop the chage of self update.')
    args = parser.parse_args()

    if (args.stash):
        stash_tools(replace)
        stash_file()
    else:
        pop_file()
        pop_tools(replace)


if __name__ == '__main__':
    main()
