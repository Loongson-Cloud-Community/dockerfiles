#!/bin/bash

set -o pipefail

set +e

# Script trace mode
if [ "${DEBUG_MODE}" == "true" ]; then
    set -o xtrace
fi

# Default Zabbix installation name
# Used only by Zabbix web-interface
: ${ZBX_SERVER_NAME:="Zabbix docker"}
# Default Zabbix server host
: ${ZBX_SERVER_HOST:="zabbix-server"}
# Default Zabbix server port number
: ${ZBX_SERVER_PORT:="10051"}

# Default timezone for web interface
: ${PHP_TZ:="Europe/Riga"}

#Enable PostgreSQL timescaleDB feature:
ENABLE_TIMESCALEDB=${ENABLE_TIMESCALEDB:-"false"}

# Default directories
# Configuration files directory
ZABBIX_ETC_DIR="/etc/zabbix"
# Web interface www-root directory
ZABBIX_WWW_ROOT="/usr/share/zabbix"

# usage: file_env VAR [DEFAULT]
# as example: file_env 'MYSQL_PASSWORD' 'zabbix'
#    (will allow for "$MYSQL_PASSWORD_FILE" to fill in the value of "$MYSQL_PASSWORD" from a file)
# unsets the VAR_FILE afterwards and just leaving VAR
file_env() {
    local var="$1"
    local fileVar="${var}_FILE"
    local defaultValue="${2:-}"

    if [ "${!var:-}" ] && [ "${!fileVar:-}" ]; then
        echo "**** Both variables $var and $fileVar are set (but are exclusive)"
        exit 1
    fi

    local val="$defaultValue"

    if [ "${!var:-}" ]; then
        val="${!var}"
        echo "** Using ${var} variable from ENV"
    elif [ "${!fileVar:-}" ]; then
        if [ ! -f "${!fileVar}" ]; then
            echo "**** Secret file \"${!fileVar}\" is not found"
            exit 1
        fi
        val="$(< "${!fileVar}")"
        echo "** Using ${var} variable from secret file"
    fi
    export "$var"="$val"
    unset "$fileVar"
}

escape_spec_char() {
    local var_value=$1

    var_value="${var_value//\\/\\\\}"
    var_value="${var_value//[$'\n']/}"
    var_value="${var_value//\//\\/}"
    var_value="${var_value//./\\.}"
    var_value="${var_value//\*/\\*}"
    var_value="${var_value//^/\\^}"
    var_value="${var_value//\$/\\\$}"
    var_value="${var_value//\&/\\\&}"
    var_value="${var_value//\[/\\[}"
    var_value="${var_value//\]/\\]}"

    echo "$var_value"
}

update_config_var() {
    local config_path=$1
    local var_name=$2
    local var_value=$3
    local is_multiple=$4

    if [ ! -f "$config_path" ]; then
        echo "**** Configuration file '$config_path' does not exist"
        return
    fi

    echo -n "** Updating '$config_path' parameter \"$var_name\": '$var_value'... "

    # Remove configuration parameter definition in case of unset parameter value
    if [ -z "$var_value" ]; then
        sed -i -e "/^$var_name=/d" "$config_path"
        echo "removed"
        return
    fi

    # Remove value from configuration parameter in case of double quoted parameter value
    if [ "$var_value" == '""' ]; then
        sed -i -e "/^$var_name=/s/=.*/=/" "$config_path"
        echo "undefined"
        return
    fi

    # Escaping characters in parameter value and name
    var_value=$(escape_spec_char "$var_value")
    var_name=$(escape_spec_char "$var_name")

    if [ "$(grep -E "^$var_name=" $config_path)" ] && [ "$is_multiple" != "true" ]; then
        sed -i -e "/^$var_name=/s/=.*/=$var_value/" "$config_path"
        echo "updated"
    elif [ "$(grep -Ec "^# $var_name=" $config_path)" -gt 1 ]; then
        sed -i -e  "/^[#;] $var_name=$/i\\$var_name=$var_value" "$config_path"
        echo "added first occurrence"
    else
        sed -i -e "/^[#;] $var_name=/s/.*/&\n$var_name=$var_value/" "$config_path"
        echo "added"
    fi

}

# Check prerequisites for MySQL database
check_variables() {
    : ${DB_SERVER_HOST:="mysql-server"}
    : ${DB_SERVER_PORT:="3306"}
    USE_DB_ROOT_USER=false
    CREATE_ZBX_DB_USER=false
    file_env MYSQL_USER
    file_env MYSQL_PASSWORD

    if [ ! -n "${MYSQL_USER}" ] && [ "${MYSQL_RANDOM_ROOT_PASSWORD}" == "true" ]; then
        echo "**** Impossible to use MySQL server because of unknown Zabbix user and random 'root' password"
        exit 1
    fi

    if [ ! -n "${MYSQL_USER}" ] && [ ! -n "${MYSQL_ROOT_PASSWORD}" ] && [ "${MYSQL_ALLOW_EMPTY_PASSWORD}" != "true" ]; then
        echo "*** Impossible to use MySQL server because 'root' password is not defined and it is not empty"
        exit 1
    fi

    if [ "${MYSQL_ALLOW_EMPTY_PASSWORD}" == "true" ] || [ -n "${MYSQL_ROOT_PASSWORD}" ]; then
        USE_DB_ROOT_USER=true
        DB_SERVER_ROOT_USER="root"
        DB_SERVER_ROOT_PASS=${MYSQL_ROOT_PASSWORD:-""}
    fi

    [ -n "${MYSQL_USER}" ] && CREATE_ZBX_DB_USER=true

    # If root password is not specified use provided credentials
    : ${DB_SERVER_ROOT_USER:=${MYSQL_USER}}
    [ "${MYSQL_ALLOW_EMPTY_PASSWORD}" == "true" ] || DB_SERVER_ROOT_PASS=${DB_SERVER_ROOT_PASS:-${MYSQL_PASSWORD}}
    DB_SERVER_ZBX_USER=${MYSQL_USER:-"zabbix"}
    DB_SERVER_ZBX_PASS=${MYSQL_PASSWORD:-"zabbix"}

    DB_SERVER_DBNAME=${MYSQL_DATABASE:-"zabbix"}
}

check_db_connect() {
    echo "********************"
    echo "* DB_SERVER_HOST: ${DB_SERVER_HOST}"
    echo "* DB_SERVER_PORT: ${DB_SERVER_PORT}"
    echo "* DB_SERVER_DBNAME: ${DB_SERVER_DBNAME}"
    if [ "${DEBUG_MODE}" == "true" ]; then
        if [ "${USE_DB_ROOT_USER}" == "true" ]; then
            echo "* DB_SERVER_ROOT_USER: ${DB_SERVER_ROOT_USER}"
            echo "* DB_SERVER_ROOT_PASS: ${DB_SERVER_ROOT_PASS}"
        fi
        echo "* DB_SERVER_ZBX_USER: ${DB_SERVER_ZBX_USER}"
        echo "* DB_SERVER_ZBX_PASS: ${DB_SERVER_ZBX_PASS}"
    fi
    echo "********************"

    WAIT_TIMEOUT=5

    if [ "${ZBX_DB_ENCRYPTION}" == "true" ]; then
        ssl_opts="--ssl --ssl-ca=${ZBX_DB_CA_FILE} --ssl-key=${ZBX_DB_KEY_FILE} --ssl-cert=${ZBX_DB_CERT_FILE}"
    fi

    while [ ! "$(mysqladmin ping -h ${DB_SERVER_HOST} -P ${DB_SERVER_PORT} -u ${DB_SERVER_ROOT_USER} \
                --password="${DB_SERVER_ROOT_PASS}" --silent --connect_timeout=10 $ssl_opts)" ]; do
        echo "**** MySQL server is not available. Waiting $WAIT_TIMEOUT seconds..."
        sleep $WAIT_TIMEOUT
    done
}

prepare_web_server() {
    APACHE_SITES_DIR=/etc/apache2/conf.d

    echo "** Adding Zabbix virtual host (HTTP)"
    if [ -f "$ZABBIX_ETC_DIR/apache.conf" ]; then
        ln -s "$ZABBIX_ETC_DIR/apache.conf" "$APACHE_SITES_DIR/zabbix.conf"
    else
        echo "**** Impossible to enable HTTP virtual host"
    fi

    if [ -f "/etc/ssl/apache2/ssl.crt" ] && [ -f "/etc/ssl/apache2/ssl.key" ]; then
        echo "** Adding Zabbix virtual host (HTTPS)"
        if [ -f "$ZABBIX_ETC_DIR/apache_ssl.conf" ]; then
            ln -s "$ZABBIX_ETC_DIR/apache_ssl.conf" "$APACHE_SITES_DIR/zabbix_ssl.conf"
        else
            echo "**** Impossible to enable HTTPS virtual host"
        fi
    else
        echo "**** Impossible to enable SSL support for Apache2. Certificates are missed."
    fi
}

prepare_zbx_web_config() {
    local server_name=""

    echo "** Preparing Zabbix frontend configuration file"

    ZBX_WWW_ROOT="/usr/share/zabbix"
    ZBX_WEB_CONFIG="$ZABBIX_ETC_DIR/web/zabbix.conf.php"
    PHP_CONFIG_FILE="/etc/php7/conf.d/99-zabbix.ini"

    update_config_var "$PHP_CONFIG_FILE" "max_execution_time" "${ZBX_MAXEXECUTIONTIME:-"600"}"
    update_config_var "$PHP_CONFIG_FILE" "memory_limit" "${ZBX_MEMORYLIMIT:-"128M"}" 
    update_config_var "$PHP_CONFIG_FILE" "post_max_size" "${ZBX_POSTMAXSIZE:-"16M"}"
    update_config_var "$PHP_CONFIG_FILE" "upload_max_filesize" "${ZBX_UPLOADMAXFILESIZE:-"2M"}"
    update_config_var "$PHP_CONFIG_FILE" "max_input_time" "${ZBX_MAXINPUTTIME:-"300"}"
    update_config_var "$PHP_CONFIG_FILE" "date.timezone" "${PHP_TZ}"

    ZBX_HISTORYSTORAGETYPES=${ZBX_HISTORYSTORAGETYPES:-"[]"}

    # Escaping characters in parameter value
    server_name=$(escape_spec_char "${ZBX_SERVER_NAME}")
    server_user=$(escape_spec_char "${DB_SERVER_ZBX_USER}")
    server_pass=$(escape_spec_char "${DB_SERVER_ZBX_PASS}")
    history_storage_url=$(escape_spec_char "${ZBX_HISTORYSTORAGEURL}")
    history_storage_types=$(escape_spec_char "${ZBX_HISTORYSTORAGETYPES}")

    ZBX_DB_KEY_FILE=$(escape_spec_char "${ZBX_DB_KEY_FILE}")
    ZBX_DB_CERT_FILE=$(escape_spec_char "${ZBX_DB_CERT_FILE}")
    ZBX_DB_CA_FILE=$(escape_spec_char "${ZBX_DB_CA_FILE}")

    sed -i \
        -e "s/{DB_SERVER_HOST}/${DB_SERVER_HOST}/g" \
        -e "s/{DB_SERVER_PORT}/${DB_SERVER_PORT}/g" \
        -e "s/{DB_SERVER_DBNAME}/${DB_SERVER_DBNAME}/g" \
        -e "s/{DB_SERVER_SCHEMA}/${DB_SERVER_SCHEMA}/g" \
        -e "s/{DB_SERVER_USER}/$server_user/g" \
        -e "s/{DB_SERVER_PASS}/$server_pass/g" \
        -e "s/{ZBX_SERVER_HOST}/${ZBX_SERVER_HOST}/g" \
        -e "s/{ZBX_SERVER_PORT}/${ZBX_SERVER_PORT}/g" \
        -e "s/{ZBX_SERVER_NAME}/$server_name/g" \
        -e "s/{ZBX_DB_ENCRYPTION}/${ZBX_DB_ENCRYPTION:-"false"}/g" \
        -e "s/{ZBX_DB_KEY_FILE}/${ZBX_DB_KEY_FILE}/g" \
        -e "s/{ZBX_DB_CERT_FILE}/${ZBX_DB_CERT_FILE}/g" \
        -e "s/{ZBX_DB_CA_FILE}/${ZBX_DB_CA_FILE}/g" \
        -e "s/{ZBX_DB_VERIFY_HOST}/${ZBX_DB_VERIFY_HOST:-"false"}/g" \
        -e "s/{ZBX_DB_CIPHER_LIST}/${ZBX_DB_CIPHER_LIST}/g" \
        -e "s/{DB_DOUBLE_IEEE754}/${DB_DOUBLE_IEEE754:-"true"}/g" \
        -e "s/{ZBX_HISTORYSTORAGEURL}/$history_storage_url/g" \
        -e "s/{ZBX_HISTORYSTORAGETYPES}/$history_storage_types/g" \
    "$ZBX_WEB_CONFIG"

    if [ -n "${ZBX_SESSION_NAME}" ]; then
        cp "$ZBX_WWW_ROOT/include/defines.inc.php" "/tmp/defines.inc.php_tmp"
        sed "/ZBX_SESSION_NAME/s/'[^']*'/'${ZBX_SESSION_NAME}'/2" "/tmp/defines.inc.php_tmp" > "$ZBX_WWW_ROOT/include/defines.inc.php"
        rm -f "/tmp/defines.inc.php_tmp"
    fi

    if [ "${ENABLE_WEB_ACCESS_LOG:-"true"}" == "false" ]; then
        sed -ri \
            -e 's!^(\s*CustomLog)\s+\S+!\1 /dev/null!g' \
            "/etc/apache2/httpd.conf"
    fi
}

#################################################

echo "** Deploying Zabbix web-interface (Apache) with MySQL database"

check_variables
check_db_connect
prepare_web_server
prepare_zbx_web_config

echo "########################################################"

if [ "$1" != "" ]; then
    echo "** Executing '$@'"
    exec "$@"
elif [ -f "/usr/sbin/httpd" ]; then
    echo "** Executing HTTPD"
    exec /usr/sbin/httpd -D FOREGROUND
else
    echo "Unknown instructions. Exiting..."
    exit 1
fi

#################################################
