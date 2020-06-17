#!/bin/sh -e

# shellcheck disable=SC1091
FILENAME="zookeeper-${ZOOKEEPER_VERSION}.tar.gz"

url=$(curl --stderr /dev/null "https://www.apache.org/dyn/closer.cgi?path=/zookeeper/zookeeper-${ZOOKEEPER_VERSION}/${FILENAME}&as_json=1" | jq -r '"\(.preferred)\(.path_info)"')
# Test to see if the suggested mirror has this version, currently pre 3.4.14 versions
# do not appear to be actively mirrored. This may also be useful if closer.cgi is down.
if [[ ! $(curl -s -f -I "${url}") ]]; then
    echo "Mirror does not have desired version, downloading direct from Apache"
    url="https://archive.apache.org/dist/zookeeper/zookeeper-${ZOOKEEPER_VERSION}/${FILENAME}"
fi

echo "Downloading Zookeeper from $url"

cd /tmp
wget "${url}" -O "${FILENAME}"

wget -q https://www.apache.org/dist/zookeeper/KEYS

wget -q "https://www.apache.org/dist/zookeeper/zookeeper-${ZOOKEEPER_VERSION}/${FILENAME}.asc"
wget -q "https://www.apache.org/dist/zookeeper/zookeeper-${ZOOKEEPER_VERSION}/${FILENAME}.sha512"

sha512sum -c "${FILENAME}.sha512"
gpg --import KEYS
gpg --verify "${FILENAME}.asc"
