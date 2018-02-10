Using This Image
================
M. Edward (Ed) Borasky

1.  Create a file named `.env` for your environment variables. This name
    appears in the top-level `.gitignore` file and thus will not be
    checked into Git\!

2.  In `.env`, define the environment variables:
    
      - `HOST_RSTUDIO_PORT`: the host port you want to use to browse to
        the RStudio server
    
    Example:
    
        HOST_RSTUDIO_PORT=8786

3.  Type `docker-compose up -d`. Docker-compose will create the network
    `rstudio_default`. Then it will build the `rstudio` image if it
    doesn’t exist. Finally it will start the image in container
    `rstudio_rstudio_1`. Note that the build takes quite a while to
    finish; the R packages are built from source.

4.  Testing / troubleshooting: If everything worked, you should be able
    to browse to `HOST_RSTUDIO_PORT` on `localhost`, then log in as user
    `rstudio` with the password `rstudio`. If not, type `docker logs
    rstudio_rstudio_1` to see what happened.
    
    Note that the `terminal` has some problems with Firefox. It works
    fine in Chrome and Microsoft Edge, though.
