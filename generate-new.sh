#!/bin/bash

ORGANIZATION=$1
REPOSITORY=$2
TAG=$3
TEMPLATE=Makefile-new.template

NEW_PATH="$ORGANIZATION/$REPOSITORY/$TAG"
mkdir -pv $NEW_PATH
cp $TEMPLATE $NEW_PATH/Makefile

pushd $NEW_PATH
sed -i "s/T_REGISTRY/cr.loongnix.cn/g" Makefile
sed -i "s/T_ORGANIZATION/$ORGANIZATION/g" Makefile
sed -i "s/T_REPOSITORY/$REPOSITORY/g" Makefile
sed -i "s/T_TAG/$TAG/g" Makefile

# touch a default .gitignore file
echo "src" > .gitignore
popd

