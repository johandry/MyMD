#!/usr/bin/env bash

VERSION='1.1.0'
TITLE='Deploy My Movies Dashboard'
PROJECT="MyMD"
SOURCE_DIR=""
# SOURCE=

#=======================================================================================================
# Author: Johandry Amador <johandry@gmail.com>
# Title:  {title}
# Version: {version}
#
# Usage: {script_name} <options>
#
# Options:
#     -h, --help     Display this help message. bash {script_name} -h
#     -m             Description of the Change
#     -c, --client   Client name to deploy
#
# Description: {title} is a script to deploy MyMD to GitHub and make it a Web Application
#              in http://www.johandry.com/MyMD
#
#
# Report Issues or create Pull Requests in http://github.com/johandry/{project_name}
#=======================================================================================================

[[ ! -e "$HOME/bin/common.sh" ]] && \
  echo "~/bin/common.sh not found, install it with: " && \
  echo "    curl -s http://cs.johandry.com/install | bash" && \
  exit 1

source ~/bin/common.sh

desc=
client=

while (( $# ))
do
  case $1 in
    # -h and --help are covered in common.sh script
    -m)
      [[ -z $2 ]] && error "Need a description for the change" && \
        usage && exit 1

      desc=$2
      shift
    ;;

    --client|-c)
      [[ -z $2 ]] && error "Need a client name to deploy" && \
        usage && exit 1

      client=$2
      shift
    ;;
  esac
  shift
done

[[ -z ${desc} ]] && error "Need a description for the change" && \
  usage && exit 1
[[ -z ${client} || ! -d "${SCRIPT_DIR}/client/${client}" ]] && error "Need an existing client name to deploy" && \
  usage && exit 1

[[ ! -d "${SCRIPT_DIR}/db/artwork" ]] && error "Artwork does not exists, was the DB created?" -ec 1

if [[ ! -d "${SCRIPT_DIR}/../MyMD_gh-pages" ]]
then
  cd "${SCRIPT_DIR}/.."
  git clone -b gh-pages https://github.com/johandry/MyMD.git MyMD_gh-pages
  cd -
fi

cd "${SCRIPT_DIR}/client/${client}"
grunt dist

cd "${SCRIPT_DIR}/../MyMD_gh-pages"
rm -rf *

cp "${SCRIPT_DIR}/client/${client}/dist/." .
cp -R "${SCRIPT_DIR}/db/artwork" "${SCRIPT_DIR}/../MyMD_gh-pages/images"

git add . && \
git commit -m "${desc}" && \
git push origin gh-pages
