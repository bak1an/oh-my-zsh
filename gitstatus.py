#!/usr/bin/env python
# -*- coding: UTF-8 -*-

import sys

PY3 = False
if sys.version_info[0] == 3:
    PY3 = True

# change those symbols to whatever you prefer
symbols = {'ahead of': '↑', 'behind': '↓', 'prehash':':'}

from subprocess import Popen, PIPE

gitsym = Popen(['git', 'symbolic-ref', 'HEAD'], stdout=PIPE, stderr=PIPE)
branch, error = gitsym.communicate()

error_string = error.decode('utf-8')

if 'not a git repository' in error_string.lower():
    sys.exit(0)

branch = branch.strip()[11:]


# n - noop on python 2
# on python 3 returns native strings
n = lambda s: s
if PY3:
    n = lambda s: s if isinstance(s, str) else s.decode("utf-8")

branch = n(branch)

res, err = Popen(['git','diff','--name-status'], stdout=PIPE, stderr=PIPE).communicate()
err_string = err.decode('utf-8')
if 'fatal' in err_string:
    sys.exit(0)
changed_files = [n(namestat)[0] for namestat in res.splitlines()]
staged_files = [n(namestat)[0] for namestat in Popen(['git','diff', '--staged','--name-status'], stdout=PIPE).communicate()[0].splitlines()]
nb_changed = len(changed_files) - changed_files.count('U')
nb_U = staged_files.count('U')
nb_staged = len(staged_files) - nb_U
staged = str(nb_staged)
conflicts = str(nb_U)
changed = str(nb_changed)
nb_untracked = len(Popen(['git','ls-files','--others','--exclude-standard'],stdout=PIPE).communicate()[0].splitlines())
untracked = str(nb_untracked)
if not nb_changed and not nb_staged and not nb_U and not nb_untracked:
    clean = '1'
else:
    clean = '0'

remote = ''

if not branch: # not on any branch
    branch = symbols['prehash'] + Popen(['git','rev-parse','--short','HEAD'], stdout=PIPE).communicate()[0][:-1].decode("utf-8")
else:
    remote_name = Popen(['git','config','branch.%s.remote' % n(branch)], stdout=PIPE).communicate()[0].strip()
    if remote_name:
        merge_name = Popen(['git','config','branch.%s.merge' % n(branch)], stdout=PIPE).communicate()[0].strip()
        if n(remote_name) == '.': # local
            remote_ref = n(merge_name)
        else:
            remote_ref = 'refs/remotes/%s/%s' % (n(remote_name), n(merge_name[11:]))
        revgit = Popen(['git', 'rev-list', '--left-right', '%s...HEAD' % n(remote_ref)],stdout=PIPE, stderr=PIPE)
        revlist = revgit.communicate()[0]
        if revgit.poll(): # fallback to local
            revlist = n(Popen(['git', 'rev-list', '--left-right', '%s...HEAD' % n(merge_name)],stdout=PIPE, stderr=PIPE).communicate()[0])
        behead = revlist.splitlines()
        ahead = len([x for x in behead if n(x)[0]=='>'])
        behind = len(behead) - ahead
        if behind:
            remote += '%s%s' % (symbols['behind'], behind)
        if ahead:
            remote += '%s%s' % (symbols['ahead of'], ahead)

out = [
    branch,
    remote,
    staged,
    conflicts,
    changed,
    untracked,
    clean]

if PY3:
    out = ("\n".join(out)).encode("utf-8")
    stream = sys.stdout.buffer
else:
    out = "\n".join(out)
    stream = sys.stdout

stream.write(out)

