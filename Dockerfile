FROM ubuntu:precise
MAINTAINER Michael J. Cohen, mjc@kernel.org
ENV MUSICBRAINZ_USE_PROXY 1
RUN apt-get update
RUN apt-get install -y software-properties-common python-software-properties
RUN apt-get install -y memcached
RUN apt-add-repository -y ppa:chris-lea/redis-server
ADD pgdg.asc /tmp/pgdg.asc
RUN cat /tmp/pgdg.asc | apt-key add - && rm /tmp/pgdg.asc
RUN apt-add-repository 'deb http://apt.postgresql.org/pub/repos/apt/ precise-pgdg main'
RUN apt-get update
RUN apt-get install -y redis-server
RUN apt-get install -y postgresql-9.3 postgresql-server-dev-9.3 postgresql-contrib-9.3
RUN apt-get install -y build-essential git-core libxml2-dev libpq-dev libexpat1-dev libdb-dev memcached liblocal-lib-perl cpanminus libicu-dev wget
ADD bashrc ~/.bashrc
RUN git clone --recursive https://github.com/metabrainz/musicbrainz-server.git /opt/musicbrainz-server
ADD DBDefs.pm /opt/musicbrainz-server/lib/DBDefs.pm
ADD cpanm.sh /opt/musicbrainz-server/cpanm.sh
RUN cd /opt/musicbrainz-server && cpanm --installdeps --notest .
RUN cd /opt/musicbrainz-server/postgresql-musicbrainz-unaccent && make && make install
RUN cd /opt/musicbrainz-server/postgresql-musicbrainz-collate && make && make install
RUN mkdir /tmp/dumps; pushd /tmp/dumps; wget ftp://ftp.musicbrainz.org/pub/musicbrainz/data/fullexport/20140208-002339/mbdump.tar.bz2; wget ftp://ftp.musicbrainz.org/pub/musicbrainz/data/fullexport/20140208-002339/mbdump-editor.tar.bz2; wget ftp://ftp.musicbrainz.org/pub/musicbrainz/data/fullexport/20140208-002339/mbdump-derived.tar.bz2; wget ftp://ftp.musicbrainz.org/pub/musicbrainz/data/fullexport/20140208-002339/MD5SUMS; md5sum -c MD5SUMS
RUN cd /opt/musicbrainz-server && ./admin/InitDb.pl --createdb --clean
RUN cd /opt/musicbrainz-server && ./admin/InitDb.pl --createdb --import /tmp/dumps/mbdump*.tar.bz2 --echo
