#!/usr/bin/env bash

CWD=$(pwd)
CACHE="${CWD}/../../texmf-packages"

function download_package() {
  CTAN="https://www.ctan.org/tex-archive/systems/win32/miktex/tm/packages"
  module="${1}"
  extension="${2}"
  FILE="${module}${extension}"

  if [ -f ${CACHE}/${FILE} ]; then
    if [ "x${extension}" == "x.tar.lzma" ]; then
      xz -t ${CACHE}/${FILE} &> /dev/null
      if [ $? -eq 0 ]; then
        return 0;
      fi
    elif [ "x${extension}" == "x.cab" ]; then
      7z t ${CACHE}/${FILE} &> /dev/null
      if [ $? -eq 0 ]; then
        return 0;
      fi
    elif [ "x${extension}" == "x.tar.bz2" ]; then
      bzip2 -tv ${CACHE}/${FILE} &> /dev/null
      if [ $? -eq 0 ]; then
        return 0;
      fi
    else
      echo "unkown extension! ${extension}"
      return -1;
    fi
  fi

  URL="${CTAN}/${FILE}"
  if curl -L --output /dev/null --silent --head --fail "${URL}"; then
    echo "getting ${FILE}"
    curl --silent -L -o ${CACHE}/${FILE} ${URL}
    return 0
  fi

  return 1;
}

function handle_package() {
  module="$(echo ${1} | tr -d '[[:space:]]' )"
  download_package ${module} ".tar.lzma" && return
  download_package ${module} ".cab" && return
  download_package ${module} ".tar.bz2" && return
  echo "ERROR ${module} is not available as .tar.lzma or .cab or .tar.bz2"
}

export -f download_package
export -f handle_package
export CACHE

mkdir -p ${CACHE}
rm -rf texmf
mkdir -p texmf

cat Resources/Packages.txt | xargs -P 10 -I {} bash -c 'handle_package "$@"' _ {}

# some extra packages, that are not part of packages.txt but are needed by LyX
handle_package 'graphics-def'
handle_package 'ascii-font'
handle_package 'ifsym'

pushd texmf
echo "extracting .tar.lzma"
for i in $(ls ${CACHE}/*.tar.lzma); do
  MSYS='winsymlinks:lnk' tar --lzma -xmf ${i}
  basename -s .tar.lzma "${i}" >> texmf/installed-packages.txt
done
echo "extracting .cab"
for i in $(ls ${CACHE}/*.cab); do
  MSYS='winsymlinks:lnk' 7z x ${i} &>/dev/null
  basename -s .cab "${i}" >> texmf/installed-packages.txt
done
echo "extracting .tar.bz2"
for i in $(ls ${CACHE}/*.tar.bz2) ; do
    MSYS='winsymlinks:lnk' tar jxmf ${i}
    basename -s .tar.bz2 "${i}" >> texmf/installed-packages.txt
done
popd

find -L . -type l -ls -delete
