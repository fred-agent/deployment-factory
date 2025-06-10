# Copyright Thales 2025
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

#!/usr/bin/env bash

# -----------------------------------------------------------------------------
# Functions
# -----------------------------------------------------------------------------

function usage
{
    echo "Usage: $0 -a <admin> -h <host> -u <user> -p <password> -d <database>" >&2
    exit 1
}

function check_opts
{
    if [[ -z "$DB_ADMIN_USER" || -z "$DB_HOST" || -z "$DB_USER" || -z "$DB_PASS" || -z "$DB_NAME" ]]
    then
        [ -z "$DB_ADMIN_USER" ] && echo "-a|--admin is not set" >&2
        [ -z "$DB_HOST" ] && echo "-h|--host is not set" >&2
        [ -z "$DB_USER" ] && echo "-u|--user is not set" >&2
        [ -z "$DB_PASS" ] && echo "-p|--password is not set" >&2
        [ -z "$DB_NAME" ] && echo "-d|--database is not set" >&2
        usage
    fi
}

# -----------------------------------------------------------------------------
# Main
# -----------------------------------------------------------------------------

OPTIONS=a:h:u:p:d:
LONGOPTS=admin:,host:,user:,password:,database:

eval set -- "$(getopt --options=$OPTIONS --longoptions=$LONGOPTS --name "$0" -- "$@")" || usage

while true; do
    case "$1" in
        -a|--admin) DB_ADMIN_USER="$2"; shift 2 ;;
        -h|--host) DB_HOST="$2"; shift 2 ;;
        -u|--user) DB_USER="$2"; shift 2 ;;
        -p|--password) DB_PASS="$2"; shift 2 ;;
        -d|--database) DB_NAME="$2"; shift 2 ;;
        --) shift; break ;;
        *) usage ;;
    esac
done

check_opts

PSQL_CMD="psql -U $DB_ADMIN_USER -h $DB_HOST -d postgres"

# Create user if it does not exists
$PSQL_CMD -c "\du" | grep "$DB_USER" || $PSQL_CMD -c "CREATE ROLE $DB_USER NOSUPERUSER LOGIN PASSWORD '$DB_PASS'"

# Create database if it does not exists
$PSQL_CMD -c "\l" | grep -q $DB_NAME || $PSQL_CMD -c "CREATE DATABASE $DB_NAME OWNER=$DB_USER"

# Remove permissions from public
$PSQL_CMD -c "REVOKE ALL ON DATABASE $DB_NAME FROM PUBLIC"

# Grant persmission on database to application user
$PSQL_CMD -c "GRANT CONNECT ON DATABASE $DB_NAME TO $DB_USER"
