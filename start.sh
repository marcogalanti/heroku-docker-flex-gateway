#!/usr/bin/env bash
set -e

if [ -z "$REDIS_URL" ]; then
echo "configuring Heroku Key-Value Store as shared storage for Flex Gateway ..."

#This regular expression is used to parse and extract information from a PostgreSQL database connection string in the format "rediss://user:password@host:port".
#
# - "^rediss://" is the starting point of the string, indicating that it begins with the protocol "rediss://".
# - "([^:]+)" captures any characters that are not a colon ":" one or more times, representing the username in the connection string.
# - "([^@]+)" captures any characters that are not an "@" symbol one or more times, representing the password in the connection string.
# - "@([^:]+)" captures any characters that are not a colon ":" after the "@" symbol, representing the host or server address in the connection string.
# - "([^/]+)" captures any characters that are not a forward slash "/" one or more times, representing the port number in the connection string.

# assuming the add-on URL is the default REDIS_URL

regex="^rediss://([^:]+):([^@]+)@([^:]+):([^/]+)"
if [[ $REDIS_URL =~ $regex ]]; then

export REDIS_USER=${BASH_REMATCH[1]}
export REDIS_PASSWORD=${BASH_REMATCH[2]}
export REDIS_HOST=${BASH_REMATCH[3]}
export REDIS_PORT=${BASH_REMATCH[4]}

FG_CONFIG_DIR="/etc/mulesoft/flex-gateway/conf.d/custom"
FG_CONFIG_SHARED_STORAGE_FILE="${FG_CONFIG_DIR}/shared-storage-redis.yaml"

mkdir -p ${FG_CONFIG_DIR}

cat << EOF > ${FG_CONFIG_SHARED_STORAGE_FILE}
apiVersion: gateway.mulesoft.com/v1alpha1
kind: Configuration
metadata:
name: shared-storage-redis
spec:
sharedStorage:
redis:
    address: ${REDIS_HOST}:${REDIS_PORT}
    username: ${REDIS_USER}
    password: ${REDIS_PASSWORD}
    tls:
        skipValidation: true
        minVersion: "1.1"
        maxVersion: "1.3"
EOF

echo "Configuration file ${FG_CONFIG_SHARED_STORAGE_FILE} created successfully"
fi
fi

/init