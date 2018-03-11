Using Docker from Windows 10 Pro / Windows Subsystem for Linux / Ubuntu
================

Getting started
---------------

1.  You'll need Windows 10 Pro and Docker for Windows installed.
2.  Install Ubuntu for Windows Subsystem for Linux (WSL) from the Microsoft Store.
3.  Read the blog post that explains what you're going to do - <https://blogs.msdn.microsoft.com/commandline/2017/12/08/cross-post-wsl-interoperability-with-docker/>.

Installation
------------

1.  Open an Ubuntu terminal.
2.  Clone this repository via `https` in your Ubuntu home. You're just going to read, not commit. ***Please don't push to the repository; `git` on Ubuntu messes with line endings!***
3.  `cd data-science-pet-containers/win10pro-wsl-ubuntu-tools`. Run the script `install-docker-relay.bash`. This implements the manual steps in the blog post.
4.  Close the terminal when the install finishes.

Running
-------

1.  Open a new Ubuntu terminal.
2.  `cd data-science-pet-containers/win10pro-wsl-ubuntu-tools`.
3.  `sudo ~/docker-relay`. Enter your password if necessary. The relay process is now running.
4.  Open another Ubuntu terminal.
5.  `cd data-science-pet-containers/containers`. The standard Docker commands should now work. One caution: make sure you are using `docker-compose.exe`, not the bare `docker-compose`.

References
----------

Craig Wilhite, "WSL Interoperability with Docker", <https://blogs.msdn.microsoft.com/commandline/2017/12/08/cross-post-wsl-interoperability-with-docker/>
