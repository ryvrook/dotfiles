# agenix rules file. Maps each .age secret to the keys allowed to decrypt it.
# Edit secrets from this directory:  cd secrets && agenix -e <name>.age
# After adding/removing keys:        cd secrets && agenix --rekey
#
# NOTE: the host key of the NixOS machine MUST be listed on every secret,
# because agenix decrypts at activation using /etc/ssh/ssh_host_ed25519_key.
# On the machine:  cat /etc/ssh/ssh_host_ed25519_key.pub
# then add it to `hosts` below and run `agenix --rekey` (on the machine you
# can rekey with the host identity: agenix --rekey -i /etc/ssh/ssh_host_ed25519_key).
let
  # github.com/ryvrook.keys (1Password-backed user keys)
  users = [
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIIoWx4/Tb6RdokMIweOMRuhtZbj3+LNwves+gxoC1uRW"
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAILEtVzIbnAEsxYMWYmczpM4uzZAXJpcR5kMovRGV7sNH"
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIG13G0zoBFUItdKeGQ+EIL/OuA6d4eC21GlyjIQJEpIw"
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIIEHVaZdwY2YiGodSrMNlgt/yXRX8D8Wt+vJId+UFzxb"
  ];

  # TODO(ryv): add the ryv host key here, then `agenix --rekey`.
  #   "ssh-ed25519 AAAA... root@ryv"
  hosts = [ ];
in
{
  "ryv-password.age".publicKeys = users ++ hosts;
}
