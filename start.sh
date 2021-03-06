#!/bin/bash

set -e

ACCESS_KEY=${ACCESS_KEY:?"ACCESS_KEY env variable is required"}
SECRET_KEY=${SECRET_KEY:?"SECRET_KEY env variable is required"}
S3_PATH=${S3_PATH:?"S3_PATH env variable is required"}
DATA_PATH=${DATA_PATH:-/data/}
CRON_SCHEDULE=${CRON_SCHEDULE:-0 1 * * *}
PARAMS=${PARAMS}

echo "access_key=$ACCESS_KEY" >> /root/.s3cfg
echo "secret_key=$SECRET_KEY" >> /root/.s3cfg

if [[ "$1" == 'no-cron' ]]; then
    exec /usr/bin/s3cmd sync $PARAMS "$DATA_PATH" "$S3_PATH"
elif [[ "$1" == 'download' ]]; then
  exec /usr/bin/s3cmd sync $PARAMS "$S3_PATH" "$DATA_PATH"
elif [[ "$1" == 'delete' ]]; then
    exec /usr/bin/s3cmd del -r "$S3_PATH"
else
    echo "$CRON_SCHEDULE /usr/bin/s3cmd sync $PARAMS \"$DATA_PATH\" \"$S3_PATH\"" | crontab -
    exec cron -f
fi
