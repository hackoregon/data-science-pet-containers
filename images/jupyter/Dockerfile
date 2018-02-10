FROM intelpython/intelpython3_core
LABEL maintainer="M. Edward (Ed) Borasky <znmeb@znmeb.net>"

# need gnupg for PostgreSQL repo
RUN apt-get update \
  && apt-get install -qqy --no-install-recommends \
  gnupg \
  && apt-get clean

# add PostgreSQL client tools
RUN mkdir -p /etc/apt/sources.list.d/
COPY pgdg.list /etc/apt/sources.list.d/
RUN wget --quiet -O - https://www.postgresql.org/media/keys/ACCC4CF8.asc | apt-key add - \
  && wget --quiet -O - https://www.postgresql.org/media/keys/ACCC4CF8.asc | apt-key add - \
  && apt-get update \
  && apt-get install -qqy --no-install-recommends \
  libpq-dev \
  postgresql-client-10 \
  && apt-get clean

# add a non-privileged user
RUN useradd -c "Hack Oregon" -s /bin/bash -U -m hacko
RUN chown -R hacko:hacko /home/hacko
WORKDIR /home/hacko
USER hacko

# just add Jupyter, pandas and psycopg2 - let users install what they need!
RUN conda create --yes --quiet -n jupyter python=3 jupyter pandas psycopg2
ARG CONTAINER_JUPYTER_PORT
EXPOSE $CONTAINER_JUPYTER_PORT
RUN echo "source activate jupyter; jupyter notebook --no-browser --ip=0.0.0.0 --port=$CONTAINER_JUPYTER_PORT" \
  > /home/hacko/start-notebook.bash
CMD [ "/bin/bash", "-v", "/home/hacko/start-notebook.bash" ]
