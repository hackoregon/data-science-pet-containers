Using Docker from Windows 10 Pro / Windows Subsystem for Linux / Ubuntu
================

Getting started
---------------

1.  You'll need Windows 10 Pro and Docker for Windows installed. See [Install Docker for Windows](https://docs.docker.com/docker-for-windows/install/).
2.  Enable Hyper-V Windows Virtualization. See [Install Hyper-V on Windows 10](https://docs.microsoft.com/en-us/virtualization/hyper-v-on-windows/quick-start/enable-hyper-v). *Note: This disables the ability to run Oracle VirtualBox machines.*
2.  Install Ubuntu for Windows Subsystem for Linux (WSL) from the Microsoft Store. (see [Install the Windows Subsystem for Linux](https://docs.microsoft.com/en-us/windows/wsl/install-win10#install-the-windows-subsystem-for-linux))
3.  Read the blog post that explains what you're going to do - <https://blogs.msdn.microsoft.com/commandline/2017/12/08/cross-post-wsl-interoperability-with-docker/>.


Installation
------------

1.  Open an Ubuntu terminal.
2.  Clone this repository. Both `https` and `ssh` now work, and the line endings issues from previous versions have been fixed.
3.  `cd data-science-pet-containers/win10pro-wsl-ubuntu-tools`. Run the script `install-docker-relay.bash`. This implements the manual steps in the blog post. It also installs the correct version of `docker-compose`; see <https://github.com/hackoregon/data-science-pet-containers/issues/38> for the issue.
4.  Close the terminal when the install finishes.

Running
-------

1.  Open a new Ubuntu terminal.
2.  `cd data-science-pet-containers/win10pro-wsl-ubuntu-tools`.
3.  `sudo ~/docker-relay`. Enter your password if necessary. The relay process is now running.
4.  Open another Ubuntu terminal.
5.  `cd data-science-pet-containers/containers`. The standard Docker commands should now work. One caution: make sure you are using `/usr/local/bin/docker-compose`, not the Windows executable `docker-compose.exe`.

References
----------

Craig Wilhite, "WSL Interoperability with Docker", <https://blogs.msdn.microsoft.com/commandline/2017/12/08/cross-post-wsl-interoperability-with-docker/>
