#!/bin/bash

# Configure Git
# git config --global user.name "Denis Burenko"
# git config --global user.email "burenko@"
# git config --global push.default simple

bootstrap_path=$(readlink -f "$0")
bootstrap_dir=$(dirname "$bootstrap_path")
echo "start denis-bu bootstrap in $bootstrap_dir"

UBIN=$HOME/bu-bin
TOOLSET=$HOME/bu-tools
mkdir -p $UBIN
mkdir -p $TOOLSET


# Install packages

sudo apt-get update
sudo apt-get install build-essential texinfo libx11-dev libxpm-dev libjpeg-dev libpng-dev \
  libgif-dev libtiff-dev libgtk2.0-dev libncurses-dev gnutls-dev libgtk-3-dev libpq-dev libssl-dev \
  openssl libffi-dev zlib1g-dev libevent-dev libncurses-dev

# Install tmux
echo 'set -g default-terminal "screen-256color"' > $HOME/.tmux.conf

tmux_dir=$TOOLSET/tmux
tmux_ver=2.7
tmux_arch=tmux-2.7.tar.gz
tmux_lock=$tmux_dir/__installed_$tmux_ver
tmux_ver_dir=$tmux_dir/tmux-2.7
if [ ! -f "$tmux_lock" ]; then
  echo "Install TMux in $tmux_dir"
  mkdir -p $tmux_dir
  cd $tmux_dir

  wget https://github.com/tmux/tmux/releases/download/$tmux_ver/$tmux_arch

  tar xzvf $tmux_arch
  cd $tmux_ver_dir

  sudo apt purge -y tmux

  ./configure && make -j8 && sudo make install

  actual_tmux_ver=$(tmux -V)
  expected_tmux_ver="tmux 2.7"
  if [[ $actual_tmux_ver == *"$expected_tmux_ver"* ]]; then
    echo "TMux installed successfully"
    touch $tmux_lock
  else
    echo "TMux was not installed"
    exit -1
  fi
fi

emacs_dir=$TOOLSET/emacs
emacs_ver=26.1
emacs_arch=emacs-26.1.tar.gz
emacs_lock=$emacs_dir/__installed_$emacs_ver
if [ ! -f "$emacs_lock" ]; then
  echo "Install Emacs in $emacs_dir"
  mkdir -p $emacs_dir
  cd $emacs_dir
  wget http://mirror.tochlab.net/pub/gnu/emacs/$emacs_arch

  tar xvf $emacs_arch

  emacs_ver_dir=$emacs_dir/emacs-26.1
  cd $emacs_ver_dir
  ./configure --prefix=$emacs_ver_dir --bindir=$UBIN --with-x-toolkit=no --with-xpm=no --with-tiff=no --with-gif=no && make -j8 && make install

  actual_emacs_ver=$($UBIN/emacs --version)
  expected_emacs_ver="Emacs 26.1"
  if [[ $actual_emacs_ver == *"$expected_emacs_ver"* ]]; then
    echo "Emacs installed successfully"
    touch $emacs_lock
  else
    echo "Emacs was not installed"
    exit -1
  fi
fi

# Clean & install emacs config
rm -rf $HOME/.emacs.d

mkdir -p $HOME/.emacs.d
cp $bootstrap_dir/init.el $HOME/.emacs.d/init.el
cp -r $bootstrap_dir/lisp $HOME/.emacs.d/lisp

# Configure Pyhton

mkdir -p ~/venvs


python $bootstrap_dir/alter-bashrc.py

echo "Don't forget to source ~/.bashrc"
