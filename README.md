# dotfiles

NixOS system configuration (plain nix, no flakes) + GNU-stow-managed dotfiles
for the host `ryv` (user `ryv`).

## Layout

Stow packages (`fish/`, `niri/`, `tmux/`, ...) live at the repo root, one
directory per app, mirroring `~` inside. Next to them:

    nixos/            NixOS config; configuration.nix is the entry point
      hardware.nix    disks and kernel modules (tracked; UUIDs are not sensitive)
      local.nix       machine-local boot entries (untracked; recreate per machine)
      secret.nix      legacy password hash (untracked; only until agenix host key enrolled)
      eval.nix        eval-only entry used by CI
      modules/        desktop (niri+noctalia), greetd, services, packages
    npins/            pinned sources (nixpkgs, agenix, zen-browser, flake-compat)
    secrets/          agenix rules + encrypted secrets (committed)
    rebuild           non-flake nixos-rebuild wrapper

## Approach

Nix installs packages and manages the system. Dotfiles are plain files applied
as symlinks with GNU stow - edit a file, the app reloads it, no rebuild.

## Usage

With the repo cloned at `~/dotfiles`, run from the repo root:

    ./rebuild               # nixos-rebuild switch with pinned nixpkgs
    stow <package>...       # symlink dotfile packages into ~
    npins update            # bump pins

All packages at once (never `stow */` - that would grab nixos/ and npins/):

    stow alacritty bash fish starship bat git gh ssh tmux nvim zed \
         niri noctalia gtk desktop vesktop btop fastfetch mangohud

## Fresh install

1. Clone to `~/dotfiles`.
2. Create `nixos/secret.nix` with the login hash until the host key is enrolled:

       { ... }: { users.users.ryv.hashedPassword = "<mkpasswd -m sha-512>"; }

   Or enroll the machine: add `/etc/ssh/ssh_host_ed25519_key.pub` to the
   `hosts` list in `secrets/secrets.nix`, run `cd secrets && agenix --rekey`,
   and skip secret.nix entirely.
3. Optionally create `nixos/local.nix` (extra bootloader entries).
4. `./rebuild`
5. `mkdir -p ~/Projects ~/Pictures/Wallpapers`, then stow all packages (list above).
6. Flatpak: `flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo`
7. Vesktop: settings are pre-seeded by stow. The AskFriday plugin is a custom
   Vencord user plugin and needs a manual Vencord dev install
   (https://github.com/ryvrook/AskFriday - see its README).

## Secrets (agenix)

Age-encrypted files in `secrets/`, committed, decrypted at activation with the
host SSH key. Edit: `cd secrets && agenix -e <name>.age`. After key changes:
`agenix --rekey`.
