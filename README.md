# neofetch.el

[Neofetch](https://github.com/dylanaraps/neofetch)-style program written in pure Emacs Lisp. Does not require any external programs and runs on any operating system.

neofetch.el is a program that provides information about the system and Emacs in a fancy way.

It will output your OS (system-type), the Emacs version, the Emacs uptime, the Emacs startup time, the number of processors on your CPU and the number of Emacs sub-processes.

## Installing

Just copy neofetch.el to a directory in your `load-path`. Make sure to require 'neofetch in your configuration file so you can run it.

## Usage

Run it in Eshell. neofetch without arguments will not print a logo. Run neofetch with the path to an image to get a logo

## Screenshot

![neofetch.el](./pic.png)
