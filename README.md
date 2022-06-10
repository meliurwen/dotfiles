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

> **Note:** Unfortunately there is no in-place feature available a the moment

```sh
VSC_D="vscode/.config/Code/User/" sh -c '\
    jq --sort-keys . "${VSC_D}settings.json" > "${VSC_D}settings.json.new" && \
        mv "${VSC_D}settings.json.new" "${VSC_D}settings.json"'
```

Order alphabetically and format `argv.json`:

```sh
VSC_D="vscode/.vscode/" sh -c '\
    jq --sort-keys . "${VSC_D}argv.json" > "${VSC_D}argv.json.new" && \
        mv "${VSC_D}argv.json.new" "${VSC_D}argv.json"'
```

## Stow

```sh
stow --restow --no-folding <DIR>
```
