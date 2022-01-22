#!/bin/sh

CURRENT_SHA=$(sha256sum /usr/local/share/GeoIP/GeoLite2-City.mmdb | awk '{ print $1 }')
DOWNLOAD_URL="https://download.maxmind.com/app/geoip_download?edition_id=GeoLite2-City&license_key=$MAXMINDDB_LICENSE_KEY&suffix=tar.gz"
FILE_NAME="GeoLite2-City.tar.gz"

echo -e "---------------------------------------------------\\n
Running GeoIP2 db update process...\\n\
Current timestamp: `date +\%Y-\%m-\%d_\%H:\%M:\%S`\\n\
Downloading GeoLite2-City DB\\n\
Current SHA256: ${CURRENT_SHA}"

find . \! -name 'geoip.sh' -delete
wget ${DOWNLOAD_URL} -O ${FILE_NAME} &> /dev/null

if [[ "$?" != 0 ]]; then
    echo "Error downloading file."
    exit 1
else
    echo "Successfully downloaded file."
    echo "Extracting.."
    tar -zxf GeoLite2-City.tar.gz &> /dev/null
    NEW_SHA=$(sha256sum GeoLite2-City_*/GeoLite2-City.mmdb | awk '{ print $1 }')
    if [[ "$?" != 0 ]]; then
        echo "Error extracting file."
        exit 1
    else
    	echo "Successfully extracted."
        echo "SHA of downloaded file: ${NEW_SHA}"
    fi

fi

if [[ "${CURRENT_SHA}" != "${NEW_SHA}" ]]; then
	echo "SHA mismatch detected. Updating.."
    mv GeoLite2-City_*/GeoLite2-City.mmdb  /usr/local/share/GeoIP/GeoLite2-City.mmdb
    echo "Moved files.. It is recommended to restart the container."
    echo "---------------------------------------------------"
else
	echo "No update needed."
	echo "---------------------------------------------------"
fi
