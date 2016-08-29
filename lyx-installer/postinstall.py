#!/usr/bin/env python
'''
Post install script for lyx-installer
'''

from __future__ import print_function

import re
import os
import subprocess

SRCDIR = '/usr/share/lyx-installer/Resources'
KNOWN_MODULES = {}


def load_module_status():
    '''
    Ask mpm for the list of known packages and it's status
    '''
    lines = subprocess.check_output(["mpm", "--list"], universal_newlines=True)
    for line in lines.split('\n'):
        groups = re.split(r'\s+', line)
        status = groups[0] == 'i'
        name = groups[-1]
        KNOWN_MODULES[name] = status


def check_module(module):
    '''
    Check if the given module is installed, otherwise install
    '''
    if module not in KNOWN_MODULES:
        print('Not known module %s' % module)
        return

    if KNOWN_MODULES[module] is True:
        return

    print('installing %s' % module)
    subprocess.check_call(['mpm', '--install=%s' % module,
                           '--register-components'])
    KNOWN_MODULES[module] = True


def main():
    '''
    main entry point
    '''
    print('updating mpm database')
    subprocess.check_call(['mpm', '--update-db'])

    load_module_status()

    with open(os.path.join(SRCDIR, 'Packages.txt')) as inp:
        for line in inp.readlines():
            check_module(line.strip())

if __name__ == '__main__':
    main()
