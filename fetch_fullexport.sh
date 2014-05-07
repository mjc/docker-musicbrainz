#!/bin/bash
mkdir /tmp/dumps
cd /tmp/dumps
LATEST=`wget -q -O - ftp://ftp.musicbrainz.org/pub/musicbrainz/data/fullexport/LATEST`
wget ftp://ftp.musicbrainz.org/pub/musicbrainz/data/fullexport/$LATEST/mbdump.tar.bz2
wget ftp://ftp.musicbrainz.org/pub/musicbrainz/data/fullexport/$LATEST/mbdump-editor.tar.bz2
wget ftp://ftp.musicbrainz.org/pub/musicbrainz/data/fullexport/$LATEST/mbdump-derived.tar.bz2
wget ftp://ftp.musicbrainz.org/pub/musicbrainz/data/fullexport/$LATEST/MD5SUMS
md5sum -c MD5SUMS
