# my dotfiles

These are the dotfiles and NixOS config I use on my daily-driver machine.
I keep the system itself in a Nix flake and use GNU Stow for the files in my
home directory.

This setup is built around:

- NixOS unstable
- COSMIC
- the `ryv` user and host
- Fish, Neovim, tmux, Zed, and the rest of the apps in `nixos/modules/`
- agenix for secrets when I eventually need them

There are currently no passwords or other encrypted secrets in the repo.

## Installing on a fresh NixOS system

The easiest route is to create the user `ryv` in the NixOS installer. Pick any
password you want there—the config keeps that password and does not declare or
replace it.

Once I am logged into the new installation, the whole setup is basically:

```sh
nix shell nixpkgs#git -c \
  git clone https://github.com/ryvrook/dotfiles.git ~/dotfiles
cd ~/dotfiles

sudo nixos-generate-config \
  --show-hardware-config > nixos/hardware-configuration.nix

./rebuild

mkdir -p ~/Projects ~/Pictures/Wallpapers
stow alacritty bash fish starship bat git gh ssh tmux nvim zed \
  gtk desktop vesktop btop fastfetch mangohud
```

Then I reboot:

```sh
sudo reboot
```

That is the normal happy path. `./rebuild` runs `nixos-rebuild switch`, so the
new configuration is applied immediately and becomes the current boot
generation.

The generated `nixos/hardware-configuration.nix` is machine-specific and
ignored by Git. I give it a quick look before rebuilding, especially on a
machine with an unusual disk layout.

This config currently expects a UEFI system and uses Limine. If I need
machine-only overrides, I put them in `nixos/local.nix`; that file is also
ignored and automatically picked up by `./rebuild`.

## Using a different installer account

Using `ryv` during installation is simplest, but it is not required. If I
installed with a temporary setup user, the first `./rebuild` creates `ryv`
without a preset password. While still logged into the setup account, I run:

```sh
sudo passwd ryv
```

Then I log out and start using `ryv`. Existing local users are left alone
because mutable users are enabled.

## Rebuilding

The wrapper checks that it is running on NixOS, loads the local hardware file,
and includes `nixos/local.nix` when it exists.

```sh
./rebuild                 # switch now
./rebuild test            # activate temporarily
./rebuild boot            # use on the next boot
./rebuild dry-activate    # show activation changes
./rebuild build           # build without activating
```

To update the pinned flake inputs:

```sh
nix flake update
nix flake check --no-build
./rebuild test
```

## Dotfiles

Each app directory at the repo root mirrors a path under my home directory.
Stow turns those files into symlinks, so I can edit them here without rebuilding
NixOS.

To apply everything I currently use:

```sh
stow alacritty bash fish starship bat git gh ssh tmux nvim zed \
  gtk desktop vesktop btop fastfetch mangohud
```

I do not use `stow */`, since that would also try to treat directories like
`nixos/` and `secrets/` as dotfile packages.

If Stow finds a file that an app already created, I move or delete that file
after checking it, then run Stow again.

Flatpak is enabled by the NixOS config. I add Flathub once:

```sh
flatpak remote-add --if-not-exists \
  flathub https://flathub.org/repo/flathub.flatpakrepo
```

The Vesktop settings are included here. My AskFriday Vencord plugin still needs
its own development install from <https://github.com/ryvrook/AskFriday>.

## Passwords and agenix

I intentionally do not keep a NixOS user password in this repo. An existing
`ryv` password survives a rebuild, and a newly created account gets its
password locally with `passwd`.

agenix is still installed and its NixOS module is enabled, so I can use it for
service tokens or other secrets later. The empty rules file lives at
`secrets/secrets.nix`.

When I add my first secret, I will:

1. Add the machine's public SSH host key to `secrets/secrets.nix`.
2. Add a rule for the new `.age` file.
3. Run `cd secrets && agenix -e <name>.age`.
4. Add the matching `age.secrets.<name>` declaration to a NixOS module.

The host public key is available at:

```sh
cat /etc/ssh/ssh_host_ed25519_key.pub
```

## Test VM

I can also try the configuration in QEMU without touching my installed system:

```sh
nix run .#vm
```

The VM uses 8 GiB of RAM, 4 vCPUs, and a 20 GiB disk. It logs into the graphical
session as `ryv` automatically and has no preset password. Passwordless sudo is
enabled only inside this disposable VM.

The VM runner expects QEMU at `/usr/bin/qemu-img` and
`/usr/bin/qemu-system-x86_64`. To start over, I delete `ryv-vm.qcow2`.

To evaluate or build it without launching:

```sh
nix flake check --no-build
nix build .#vm
```
