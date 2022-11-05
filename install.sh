#!/usr/bin/env bash

# folder.sh
function folder() {
  #statements
  local file=$1
  local new_folder=`head -n 1 $file/README.md | sed 's/# //g'`

  mv $file $new_folder
}
# readme.sh
# 1. change word sbt to bloop-sbt
# 2. add description
# 3. change docker image name
function replace_readme_str() {
  #statements
  local file=$1/README.md
  local old=$2
  local new=$3

  perl -pi.bak -e "s/${old}/${new}/" $file
  rm -f $1/README.md.bak
}
function readme() {
  #statements
  local file=$1
  read -r -d '' DESCRIPTION <<EOF
Compiled and ran from build server \`bloop\`.

# Build note
Dependencies must be compatable with jdk8 or less.

## Tech stack
- bloop
EOF

  replace_readme_str $file "sbt" "bloop-sbt"

  replace_readme_str $file "## Tech stack" "$DESCRIPTION"

  replace_readme_str $file "- hseeberger\/scala-sbt:11\.0\.2-oraclelinux7_1\.3\.5_2\.12\.10" "- eed3si9n\/sbt"

  replace_readme_str $file "- openjdk:8-jre-alpine" "- eed3si9n\/sbt"
}
# build.sh
# 1. remove Dockerfile
# 2. add bloop Dockerfile
# 3. update/create file project/plugins.sbt
function chg_plugins() {
  #statements
  local path=$1

  if [[ -e $path/project/plugins.sbt ]]; then
    #statements
    cat .src/plugins.sbt >> $path/project/plugins.sbt

  else
    mkdir $path/project

    cp .src/plugins.sbt $path/project/plugins.sbt
  fi
}
function chg_dockerfile() {
  #statements
  local file=$1

  rm -f $file

  cp .src/Dockerfile $file
}
function build() {
  #statements
  local file=$1

  for e in `find $file -type f -name Dockerfile`; do
    #statements
    case $e in
      *java* ) chg_dockerfile $e;;
      *scala* ) chg_dockerfile $e;;
    esac
  done

  for d in `find -type d -name bin`; do
    #statements
    chg_plugins $d
  done
}

# install.sh
function install() {
  #statements
  local file=$1

  build $file

  readme $file

  folder $file
}
for d in `ls -la | grep ^d | awk '{print $NF}' | egrep -v '^\.'`; do
  install $d
done
