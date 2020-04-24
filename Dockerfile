FROM tundrasoft/alpine-base
LABEL maintainer="Abhinav A V<abhai2k@gmail.com>"

ENV PGDATA="/data" \
  POSTGRES_USER="postgres" \
  POSTGRES_PASSWORD= \
  POSTGRES_DATABASE=

# su-exec
RUN apk add --upgrade \
  pwgen \
  tzdata \
  libpq \
  postgresql-client \
  postgresql \
  postgresql-contrib \
  && rm -fr /var/log/* \
  /var/cache/apk/* \
  && mkdir -p /run/postgresql/

ADD /rootfs/ /

VOLUME ${PGDATA} /init.d

EXPOSE 5432
