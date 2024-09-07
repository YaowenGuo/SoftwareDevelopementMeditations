#!/usr/bin/env python3


import argparse
import copy
import re

class Range:
    def __init__(self, start, end, name, limit):
        self.start = start
        self.end = end
        self.name = name
        self.limit = limit

    def __str__(self):
        return f'{hex(self.start)[2:]}-{hex(self.end)[2:]} {self.limit} {self.name} {formapSize(self.start, self.end)}'
    

def parse_arguments():
    """解析 maps 文件，检查是否地址空间耗尽.

    Returns:
        maps: maps file
    """
    usage = '解析 maps 文件，检查是否地址空间耗尽.'
    parser = argparse.ArgumentParser(description=usage)

    parser.add_argument('-m', '--maps', type=str, default='maps',
                        help="指定 /proc/[pid]/maps 的输出文件")

    args = parser.parse_args()

    return (args.maps)

def readFile(file_path: str):
    range_list = []
    with open(file_path, 'r') as f:
        for line in f:
            is_map = re.match(r'^[\s]*[\da-fA-F]+-[\da-fA-F]+[\s]+[rwxsp-]{4}[\s]+[\da-fA-F]+', line)

            if (len(range_list) == 0 and not is_map): continue
            if (is_map):
                columns = line.split()
                range_star = columns[0].split('-')
                range_start = int(range_star[0], 16)
                range_end = int(range_star[1], 16)
                range = Range(range_start, range_end, " ".join(columns[5:]) if len(columns) >= 6 else '', columns[1])
                range_list.append(range)
            else: 
                break
    return range_list

def printRage(range_list):
    if (not range_list):
         return
    
    index = 1
    last_range = copy.copy(range_list[0])
    while (index < len(range_list)):
        while (last_range.end == range_list[index].start 
                and last_range.name ==  range_list[index].name ):
            last_range.end = range_list[index].end
            index += 1
        
        print(last_range)
        if (last_range.end != range_list[index].start):
            print("空闲: ", formapSize(last_range.end, range_list[index].start))
        last_range = copy.copy(range_list[index])
        index += 1

    print(last_range)

def formapSize(start, end): 
    size = end - start
    if (size < 1024):
        return f'{size}B'
    kByte = size / 1024
    if (kByte < 1024):
        return f'{kByte}KB'
    mBype = kByte / 1024
    if (mBype < 1024):
        return f'{mBype}MB'
    gBype = mBype / 1024
    return f'{gBype}GB'


def main():
    file_path = parse_arguments()
    range_list = readFile(file_path)
    printRage(range_list)

if __name__ == '__main__':
    main()