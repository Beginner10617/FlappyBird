#!/bin/zsh
set -e
clang -c main.asm -o main.o
clang main.o -o main \
  -L/opt/homebrew/opt/raylib/lib -lraylib \
  -I/opt/homebrew/opt/raylib/include \
  -framework OpenGL -framework Cocoa -framework IOKit -framework CoreVideo
rm main.o
