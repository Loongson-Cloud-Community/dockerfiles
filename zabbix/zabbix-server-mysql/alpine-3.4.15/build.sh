#!/bin/bash

set +e

if [ ! -f "Dockerfile" ]; then
    echo "Dockerfile is missing!"
    exit 1
fi

os=${PWD##*/}

version=$1
version=${version:-"latest"}

type=$2
type=${type:-"build"}

cd ../
app_component=${PWD##*/}
cd $os/

if [ "$app_component" == "zabbix-appliance" ]; then
    app_component="appliance"
fi

if [[ ! $version =~ ^[0-9]*\.[0-9]*\.[0-9]*$ ]] && [ "$version" != "latest" ]; then
    echo "Incorrect syntax of the version"
    exit 1
fi

if [ "$version" != "latest" ]; then
    VCS_REF=`svn info svn://svn.zabbix.com/tags/$version |grep "Last Changed Rev"|awk '{print $4;}'`
else
    MAJOR_VERSION=`cat Dockerfile | grep "ARG MAJOR_VERSION" | head -n1 | cut -f2 -d"="`
    MINOR_VERSION=`cat Dockerfile | grep "ARG ZBX_VERSION" | head -n1 | cut -f2 -d"."`

    VCS_REF=$MAJOR_VERSION.$MINOR_VERSION
fi

docker build -t $3/zabbix-$app_component:$os-$VCS_REF --build-arg VCS_REF="$VCS_REF" --build-arg BUILD_DATE=`date -u +"%Y-%m-%dT%H:%M:%SZ"` -f Dockerfile .

if [ "$type" != "build" ]; then
    links=""
    env_vars=""

    if [[ $app_component =~ .*mysql.* ]]; then
        links="$links --link mysql-server:mysql"
        env_vars="$env_vars -e MYSQL_DATABASE=\"zabbix\" -e MYSQL_USER=\"zabbix\" -e MYSQL_PASSWORD=\"zabbix\" -e MYSQL_RANDOM_ROOT_PASSWORD=true"

        docker rm -f mysql-server
        docker run --name mysql-server -t $env_vars -d mysql:5.7
    fi

    if [ "$links" != "" ]; then
        sleep 5
    fi

    docker rm -f zabbix-$app_component

    docker run --name zabbix-$app_component -t -d $links $env_vars zabbix-$app_component:$os-$version
fi
