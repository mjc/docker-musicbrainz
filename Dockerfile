FROM ubuntu
MAINTAINER Michael J. Cohen, mjc@kernel.org
ENV MUSICBRAINZ_USE_PROXY 1
RUN apt-get update
RUN apt-get install -y software-properties-common python-software-properties memcached
RUN add-apt-repository 'deb http://apt.postgresql.org/pub/repos/apt/ precise-pgdg main' && wget --quiet -O - https://www.postgresql.org/media/keys/ACCC4CF8.asc | apt-key add - && apt-get install postgresql-9.3 postgresql-server-dev-9.3 postgresql-contrib-9.3
RUN add-apt-repository -y ppa:chris-lea/redis-server && apt-get update &&
apt-get install -y redis-server
RUN apt-get install -qq -y build-essential git-core libxml2-dev libpq-dev libexpat1-dev libdb-dev memcached liblocal-lib-perl cpanminus libicu-dev
RUN echo 'eval $( perl -Mlocal::lib )' >> ~/.bashrc
RUN git clone --recursive https://github.com/metabrainz/musicbrainz-server.git /opt/musicbrainz-server
ADD DBDefs.pm /opt/musicbrainz-server/lib/DBDefs.pm
RUN cd /opt/musicbrainz-server && cpanm --installdeps --notest .
RUN cd /opt/musicbrainz-server/postgresql-musicbrainz-unaccent && make && make install
RUN cd /opt/musicbrainz-server/postgresql-musicbrainz-collate && make && make install
RUN mkdir /tmp/dumps; pushd /tmp/dumps; wget ftp://ftp.musicbrainz.org/pub/musicbrainz/data/fullexport/20140208-002339/mbdump.tar.bz2; wget ftp://ftp.musicbrainz.org/pub/musicbrainz/data/fullexport/20140208-002339/mbdump-editor.tar.bz2; wget ftp://ftp.musicbrainz.org/pub/musicbrainz/data/fullexport/20140208-002339/mbdump-derived.tar.bz2; wget ftp://ftp.musicbrainz.org/pub/musicbrainz/data/fullexport/20140208-002339/MD5SUMS; md5sum -c MD5SUMS
RUN cd /opt/musicbrainz-server && ./admin/InitDb.pl --createdb --clean
RUN cd /opt/musicbrainz-server && ./admin/InitDb.pl --createdb --import /tmp/dumps/mbdump*.tar.bz2 --echo
