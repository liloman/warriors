#!/usr/bin/env python

# Script to insert all your previous task into timewarrior to track them all!

#requires 
# pip install tasklib --user

import re
from tasklib import TaskWarrior

tw = TaskWarrior(data_location='~/.task')

#  for task in tw.tasks.all():
#     print task['description'].encode('utf-8').strip()
    
# print ta['description']

undo = open('undo.data', 'r')
prog = re.compile('^old|new \[.*\]$')

for line in undo:
    if prog.match(line):
        print line

undo.close()
