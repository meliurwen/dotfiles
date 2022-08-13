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
codium --list-extensions > vscode/codium-extensions.list
```

Install all the extensions listed into a file (any line that starts with `#` will get ignored):

```sh
cat vscode/codium-extensions.list | grep -v '^#' | xargs -L1 codium --install-extension
```

Order alphabetically and format `settings.json`:

> **Note 1:** Unfortunately there is no in-place feature available a the moment
>
> **Note 2:** Manually remove all comments (`//` or `/* */`) first; they are
> [non-standard](https://www.ecma-international.org/publications-and-standards/standards/ecma-404/),
> [bad practice](https://web.archive.org/web/20180814033116/https://plus.google.com/+DouglasCrockfordEsq/posts/RK8qyGVaGSr)
> and [not supported](https://github.com/stedolan/jq/wiki/FAQ) by `jq`.

```sh
VSC_D="vscode/.config/Code/User/" VSC_J="settings.json" sh -c '\
    jq --indent 2 --sort-keys . "${VSC_D}${VSC_J}" > "${VSC_D}${VSC_J}.new" && \
        mv "${VSC_D}${VSC_J}.new" "${VSC_D}${VSC_J}"'
```

Order alphabetically and format `argv.json`:

```sh
VSC_D="vscode/.vscode/" VSC_J="argv.json" sh -c '\
    jq --indent 2 --sort-keys . "${VSC_D}${VSC_J}" > "${VSC_D}${VSC_J}.new" && \
        mv "${VSC_D}${VSC_J}.new" "${VSC_D}${VSC_J}"'
```

Format `keybindings.json`:

```sh
VSC_D="vscode/.config/Code/User/" VSC_J="keybindings.json" sh -c '\
    cat "${VSC_D}${VSC_J}" | jq --indent 2 > "${VSC_D}${VSC_J}.new" && \
        mv "${VSC_D}${VSC_J}.new" "${VSC_D}${VSC_J}"'
```

## Stow

```sh
stow --restow --no-folding <DIR>
```
