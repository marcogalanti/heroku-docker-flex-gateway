#!/usr/bin/env bash
set -e

# assuming the add-on URL is the default REDIS_URL
if [ -v REDIS_URL ]; then
    echo "configuring Heroku Key-Value Store as shared storage for Flex Gateway ..."

    #This regular expression is used to parse and extract information from a PostgreSQL database connection string in the format "rediss://user:password@host:port".
    #
    # - "^rediss://" is the starting point of the string, indicating that it begins with the protocol "rediss://".
    # - "([^:]*)" captures any characters that are not a colon ":" zero or more times, representing the username in the connection string.
    # - "([^@]+)" captures any characters that are not an "@" symbol one or more times, representing the password in the connection string.
    # - "@([^:]+)" captures any characters that are not a colon ":" after the "@" symbol, representing the host or server address in the connection string.
    # - "([^/]+)" captures any characters that are not a forward slash "/" one or more times, representing the port number in the connection string.
    regex="^rediss://([^:]*):([^@]+)@([^:]+):([^/]+)"
    if [[ $REDIS_URL =~ $regex ]]; then

        REDIS_USER=${BASH_REMATCH[1]}
        REDIS_PASSWORD=${BASH_REMATCH[2]}
        REDIS_HOST=${BASH_REMATCH[3]}
        REDIS_PORT=${BASH_REMATCH[4]}

        FG_CONFIG_DIR="${FG_CONFIG_DIR:-/etc/mulesoft/flex-gateway/conf.d/custom}"
        FG_CONFIG_SHARED_STORAGE_FILE="${FG_CONFIG_DIR}/shared-storage-redis.yaml"

        mkdir -p "${FG_CONFIG_DIR}"

        # Indentation is meaningful in YAML, make sure to use spaces correctly
        cat << EOF > "${FG_CONFIG_SHARED_STORAGE_FILE}"
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

exec /init