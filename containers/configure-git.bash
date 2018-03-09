#! /bin/bash -v

# set your email address
git config --global user.email ""

# set your name
git config --global user.name ""

# cache your username / password
# reference: https://help.github.com/articles/caching-your-github-password-in-git/#platform-linux
# Set the cache to timeout after 1 hour (setting is in seconds)
git config --global credential.helper cache --timeout=3600
