#!/bin/bash

if [[ ! -f "security/root.crt" ]]; then
    DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )"

    # create certificates if they don't exist
    cd $DIR/security && ./create-certificates.sh
fi

echo
docker-compose up -d
