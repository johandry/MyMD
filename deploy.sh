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

    --debug)
    ;;

    *)
      warn "What is this: ($1)?"
    ;;
  esac
  shift
done

[[ -z ${desc} ]] && error "Need a description for the change" -ec 1

[[ ! -d "${SCRIPT_DIR}/db/artwork" ]] && error "Artwork does not exists, was the DB created?" -ec 1

if [[ ! -d "${SCRIPT_DIR}/../MyMD_gh-pages" ]]
then
  cd "${SCRIPT_DIR}/.."
  info "Clonning the brach gh-pages"
  git clone -b gh-pages https://github.com/johandry/MyMD.git MyMD_gh-pages
  (( $? )) && error "Error cloning the brach gh-pages" -ec 1
  cd -
fi

cd "${SCRIPT_DIR}/client/web"
info "Building the production Web Application"
grunt --force
(( $? )) && error "Error building the Web Application"

info "Do you want to continue? (Ctrl+C if not)"
read

cd "${SCRIPT_DIR}/../MyMD_gh-pages"
rm -rf *

cp -r "${SCRIPT_DIR}/client/web/dist/." .
cp -r "${SCRIPT_DIR}/db/artwork" "${SCRIPT_DIR}/../MyMD_gh-pages/images"

git add . && \
git commit -m "${desc}" && \
git push origin gh-pages
