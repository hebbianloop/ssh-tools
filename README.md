# 🛠  Tools for Working Through Secure Shell (ssh) 🛠  

This package contains programs for working on remote file systems.  

## Installation

To install this package on your own machine, first clone the repository by typing this into a terminal window ::

```
git clone https://github.com/seldamat/ssh-tools.git
```

If this is your first time using git on OS X, you may need to install the Xcode command line tools and accept the license agreement.

Once you've downloaded the repository, you can add the binaries to your path by editing your .bash_profile file.

```
echo -e "\n# Add SSH-TOOLS to PATH\nexport PATH="./ssh-tools:${PATH}" >> ~/.bash_profile
source ~/.bash_profile
```

Each program in this repository requires several dependencies (see list below). Note that vpn-connect will only work on OS X.

## Software

### setup-sshkeys 

Use this program to establish keyless log in between a client and a host. You can choose to use the keychain app (recommended) for persistent passphrase management or rely on default ssh-agent settings (killed upon logout) to do so.

For more information see https://wiki.archlinux.org/index.php/SSH_keys

### occult-sshfs <in-development>

Very silly name but this program allows you to mount a remote file system unto your computer as if it were an external hard drive. This is useful for clicking, dragging and otherwise manipulating files as you would any other file on your system. 

### Acknowledgements
Thanks to M Deppe for guidance on best practices for security and encryption.
