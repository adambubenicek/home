# Home

A script I make myself at home with. Unlike a regular dotfiles repo, this script also configures my system by starting services, installing packages, and adding files to `/etc` (hence not calling it "dotfiles"). It keeps the changes at a minimum, project-related stuff lives in [distrobox](https://github.com/89luca89/distrobox) containers. It is also idempotent, which allows me to keep multiple machines in sync. 

## Prerequisities

- Fedora Workstation 38
- Private GPG key imported
