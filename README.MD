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

## Installation

```shell
sudo ./setup
```

Run command 

```shell
dvim /project/path
```
