# .dotfiles

## Dependencies

Install from a file list:

> **Note:** comments and trailing comments starting with `#` are ignored

```sh
apt-get install $(grep -vE "^\s*#" <FILEPATH> | sed -e 's/#.*//'  | tr "\n" " ")
```

## Kernel Modules

Add modules to the Linux kernel:

```sh
modprobe <module>
```

## Shell

Take note of the full path of your favorurite shell:

```sh
type -a zsh
```

Set it as default:

```sh
chsh -s /bin/zsh
```

## Fonts

Reload locally (`~/.local/share/fonts`) installed fonts:

```sh
fc-cache -f -v
```

## Gnome settings

Dump an entire subpath of the dconf database:

```sh
dconf dump <dir_subpath_inside_db> > <settings_file>.dconf
```

Populate a subpath of the dconf database:

```sh
cat <settings_file>.dconf | dconf load <dir_subpath_inside_db>
```

## VSCode/Codium

List all extensions into a file:

```sh
codium --list-extensions > codium-extensions.list
```

Install all the extensions listed into a file (any line that starts with `#` will get ignored):

```sh
cat codium-extensions.txt | grep -v '^#' | xargs -L1 codium --install-extension
```

## Stow

```sh
stow --restow --no-folding <DIR>
```
