# 🛠  Tools for Working Through Secure Shell (ssh) 🛠  

This package contains programs for working on a remote file system that may or may not be hidden behind a virtual private network (VPN)

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

Each program in this repository requires several dependencies (see list below). To enhance user-friendliness, these programs will install all dependencies if missing packages are detected. Note that vpn-connect will only work on OS X.  Support for the other programs in this repository for other OSs may be limited depending on specific distributions.

## Software

### setup-sshkeys

Use this program to establish keyless log in between a client and a host. You can choose to use the keychain app (recommended) to manage your passprhases or rely on the default ssh-agent program to do so.

For more information see https://wiki.archlinux.org/index.php/SSH_keys

### occult-sshfs

Very silly name but this program allows you to mount a remote file system unto your computer as if it were an external hard drive. This is useful for clicking, dragging and otherwise manipulating files as you would any other file on your system. 

### Acknowledgements
Thanks to M Deppe for guidance on best practices for security and encryption.
