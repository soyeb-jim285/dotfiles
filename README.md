# My dots

This is a collection of my dotfiles and scripts that I use to configure my system.

## Prerequisites

For using this dotfiles you need to have installed the following software:

- `git`
- `stow`
  In Arch Linux you can install them with the following command:

```bash
sudo pacman -S git stow
```

## Usage

- Clone this repository and go to dotfiles folder:

  ```bash
  git clone https://github.com/soyeb-jim285/dotfiles.git
  cd dotfiles
  ```

- Run the `stow` command to symlink the dotfiles to your home directory:

  ```bash
  stow .
  ```
