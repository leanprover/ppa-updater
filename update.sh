#!/usr/bin/env bash
#
# Copyright (c) 2014 Carnegie Mellon University. All rights reserved.
# Released under Apache 2.0 license as described in the file LICENSE.
#
# Author: Soonho Kong
#
#          12.04    14.04  14.10 
set -e  # Abort if any command fails
DIST_LIST="precise trusty utopic"
ORG=leanprover
REPO=lean
URGENCY=medium
AUTHOR_NAME="Leonardo de Moura"
AUTHOR_EMAIL="leonardo@microsoft.com"

if [ ! -d $REPO ] ; then
    git clone https://github.com/${ORG}/${REPO}
fi

DATETIME=`date +"%Y%m%d%H%M%S"`
DATE_STRING=`date -R`

for DIST in ${DIST_LIST}
do
    VERSION=`./get_version.sh ${REPO} ${DATETIME} ${DIST}`
    cp debian/changelog.template                               debian/changelog
    sed -i "s/##REPO##/${REPO}/g"                              debian/changelog
    sed -i "s/##VERSION##/${VERSION}/g"                        debian/changelog
    sed -i "s/##DIST##/${DIST}/g"                              debian/changelog
    sed -i "s/##URGENCY##/${URGENCY}/g"                        debian/changelog
    sed -i "s/##COMMIT_MESSAGE##/bump to version ${VERSION}/g" debian/changelog
    sed -i "s/##AUTHOR_NAME##/${AUTHOR_NAME}/g"                debian/changelog
    sed -i "s/##AUTHOR_EMAIL##/${AUTHOR_EMAIL}/g"              debian/changelog
    sed -i "s/##DATE_STRING##/${DATE_STRING}/g"                debian/changelog
    cp -r debian ${REPO}/debian
    tar -acf ${REPO}_${VERSION}.orig.tar.gz --exclude ${REPO}/.git ${REPO} 
    cd ${REPO} 
    debuild -S -sa
    cd .. 
    dput -f ppa:${ORG}/${REPO} ${REPO}_${VERSION}_source.changes
    rm -- ${REPO}_*
    rm -rf -- ${REPO}/debian debian/changelog
done
