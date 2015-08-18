#!/usr/bin/env bash
#
# Copyright (c) 2014-2015 Soonho Kong. All rights reserved.
# Released under Apache 2.0 license as described in the file LICENSE.
#
# Author: Soonho Kong
#
#          12.04    14.04  15.04
set -e  # Abort if any command fails
UPDT_PATH="`dirname \"$0\"`"
UPDT_PATH="`( cd \"$UPDT_PATH\" && pwd )`"
cd $UPDT_PATH
DIST_LIST="precise trusty vivid"
ORG=leanprover
REPO=lean
DEPS_REPO=emacs-dependencies
GIT_REMOTE_REPO=https://github.com/${ORG}/${REPO}
GIT_REMOTE_DEPS_REPO=https://github.com/${ORG}/${DEPS_REPO}
URGENCY=medium
AUTHOR_NAME="Leonardo de Moura"
AUTHOR_EMAIL="leonardo@microsoft.com"

# Check out lean if it's not here and update PREVIOUS_HASH
if [ ! -d ./${REPO} ] ; then
    git clone ${GIT_REMOTE_REPO}
    DOIT=TRUE
    cd ${REPO}
    git rev-parse HEAD > PREVIOUS_HASH
    cd ..
fi

# Update CURRENT_HASH
cd ${REPO}
git fetch --all --quiet
git reset --hard origin/master --quiet
git rev-parse HEAD > CURRENT_HASH
cd ..

# Build and Test Lean (if it fails, it stops here)
mkdir -p ${REPO}/build
cd ${REPO}/build
cmake -DCMAKE_BUILD_TYPE=RELEASE -DTCMALLOC=OFF ../src -G Ninja && ninja && ctest && ninja clean && ninja clean-olean
cd -
rm -rf ${REPO}/build

# Only run the script if there is an update
if ! cmp ${REPO}/PREVIOUS_HASH ${REPO}/CURRENT_HASH >/dev/null 2>&1
then
    DOIT=TRUE
fi

# '-f' option enforce update
if [[ $1 == "-f" ]] ; then
    DOIT=TRUE
fi

if [[ $DOIT == TRUE ]] ; then
    rm -r -f emacs-dependencies*
    git clone ${GIT_REMOTE_DEPS_REPO}
    # Copy contents of emacs-dependencies repository to main src/emacs/dependencies
    # in the main repository
    mkdir -p ${REPO}/src/emacs/dependencies
    cp -R ${DEPS_REPO}/* ${REPO}/src/emacs/dependencies
    rm -r -f ${REPO}/src/emacs/dependencies/.git
    rm -r -f ${REPO}/src/emacs/dependencies/README.md

    DATETIME=`date +"%Y%m%d%H%M%S"`
    DATE_STRING=`date -R`

    for DIST in ${DIST_LIST}
    do
        VERSION=`$UPDT_PATH/get_version.sh ${REPO} ${DATETIME} ${DIST}`
        cp debian/changelog.template                               debian/changelog
        sed -i "s/##REPO##/${REPO}/g"                              debian/changelog
        sed -i "s/##VERSION##/${VERSION}/g"                        debian/changelog
        sed -i "s/##DIST##/${DIST}/g"                              debian/changelog
        sed -i "s/##URGENCY##/${URGENCY}/g"                        debian/changelog
        sed -i "s/##COMMIT_MESSAGE##/bump to version ${VERSION}/g" debian/changelog
        sed -i "s/##AUTHOR_NAME##/${AUTHOR_NAME}/g"                debian/changelog
        sed -i "s/##AUTHOR_EMAIL##/${AUTHOR_EMAIL}/g"              debian/changelog
        sed -i "s/##DATE_STRING##/${DATE_STRING}/g"                debian/changelog
        rm -rf ${REPO}/debian
        cp -r debian ${REPO}/debian
        tar -acf ${REPO}_${VERSION}.orig.tar.gz --exclude ${REPO}/.git ${REPO}
        cd ${REPO}
        debuild -S -sa
        cd ..
        dput -f ppa:${ORG}/${REPO} ${REPO}_${VERSION}_source.changes
        rm -- ${REPO}_*
        rm -rf -- ${REPO}/debian debian/changelog
    done
else
    echo "Nothing to do."
fi
mv ${REPO}/CURRENT_HASH ${REPO}/PREVIOUS_HASH
