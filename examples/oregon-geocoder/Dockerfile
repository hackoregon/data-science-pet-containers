FROM postgis:latest
LABEL maintainer="M. Edward (Ed) Borasky <znmeb@znmeb.net>"

# copy in startup script
RUN mkdir -p /docker-entrypoint-initdb.d/
COPY geocoder_scripts/start-creation.sh /docker-entrypoint-initdb.d/
RUN chmod +x /docker-entrypoint-initdb.d/*sh

# copy in scripts that run as 'postgres'
COPY geocoder_scripts/*sql /home/postgres/
COPY geocoder_scripts/*.bash /home/postgres/
RUN chmod +x /home/postgres/*.bash
RUN chown -R postgres:postgres /home/postgres/
