import os
import re

appendix = '''
### denis-bu begin ###

alias htopu="htop -u $USER"
alias topu="top -u $USER"

SOCK="/tmp/ssh-agent-$USER-screen"
if test $SSH_AUTH_SOCK && [ $SSH_AUTH_SOCK != $SOCK ]
then
    rm -f /tmp/ssh-agent-$USER-screen
    ln -sf $SSH_AUTH_SOCK $SOCK
    export SSH_AUTH_SOCK=$SOCK
fi

tmux -2 -CC new -A -s 0
### denis-bu end ###
'''

filename = os.environ['HOME'] + '/.bashrc'

match_re = re.compile(r'\s*?### denis-bu begin.*?denis-bu end ###', re.DOTALL)

with open(filename, 'r') as f:
    bashrc_text = f.read()

bashrc_text = re.sub(match_re, '', bashrc_text) + appendix

with open(filename, 'w') as f:
    f.write(bashrc_text)
