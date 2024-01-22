# Neovim IDE

Neovim as IDE in Docker container.

## Prerequisites

#### Macos
`xclip` requires [https://www.xquartz.org/](https://www.xquartz.org/) to be installed in order to correctly forward `$DISPLAY` 

#### Linux
`xclip` requires to give necessary xhost permission.

```shell
xhost +Local:*

xhost
```

## Images

Build command

```shell
docker build -t nvim-ide .
```

Run command 

```shell
docker run --rm -it --net=host -e DISPLAY=$DISPLAY -v ${PWD}/:/root/workspace nvim-ide /bin/bash
```
