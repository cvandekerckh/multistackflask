FROM python:3.9.9-slim

RUN adduser --disabled-password multistackflaskuser
WORKDIR /home/multistackflaskuser

ENV PATH="/home/multistackflaskuser/.local/bin:$PATH" \
    _PIP_VERSION="20.2.2"

RUN apt-get update \
      && apt-get install -q -y --no-install-recommends \
      git \
      libboost-dev \
      gcc \
      && apt-get clean \
      && rm -rf /var/lib/apt/lists/*

RUN pip install --upgrade \
      pip==${_PIP_VERSION}

ENV FLASK_APP microblog.py

COPY app app
COPY migrations migrations
COPY microblog.py config.py boot_develop.sh ./
COPY Pipfile.lock Pipfile.lock
COPY Pipfile Pipfile
RUN chown -R multistackflaskuser:multistackflaskuser ./

USER multistackflaskuser
RUN pip install --user pipenv
RUN pipenv install --system --deploy --ignore-pipfile

EXPOSE 80
