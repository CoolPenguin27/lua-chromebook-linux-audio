<h1 align="center">Lua script to enable audio support on Chrome devices</h1>

This is a lua conversion of the original [chromebook-linux-audio](https://github.com/WeirdTreeThing/chromebook-linux-audio) script.
May not get updated so you should use the original.
# Instructions
1.     git clone https://github.com/CoolPenguin27/lua-chromebook-linux-audio
2.     cd lua-chromebook-linux-audio
3.     ./setup-audio

# Requirements
1. `git`
2. `lua 5.2`

# Supported Devices
Please look at the [Chrultrabook compatibility chart](https://chrultrabook.github.io/docs/docs/supported-devices.html) for more info.

# Officially Supported distros
1. Arch Linux
2. Fedora 38
3. PopOS
4. Debian 12[^1]
5. Ubuntu (23.04 preferred but 22.04 LTS should also work)
6. Linux Mint 
7. OpenSUSE
8. Void Linux

[^1]: Debian will require a custom kernel that you can install [here](https://tree123.org/chrultrabook/debian-kernel/linux-image-6.5.4-chrultrabook_6.5.4-1_amd64.deb) (The script will prompt you to install it if it detects the distro is Debian 12 or based on it).

# Other Distros
Other distros will likely work but will require you to manually install packages.
