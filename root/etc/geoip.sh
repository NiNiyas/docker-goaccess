#!/bin/bash

DOWNLOAD_URL_CITY="https://download.maxmind.com/app/geoip_download?edition_id=GeoLite2-City&license_key=$MAXMIND_LICENSE_KEY&suffix=tar.gz"
DOWNLOAD_URL_ASN="https://download.maxmind.com/app/geoip_download?edition_id=GeoLite2-ASN&license_key=$MAXMIND_LICENSE_KEY&suffix=tar.gz"
FILE_NAME_CITY="GeoLite2-City.tar.gz"
FILE_NAME_ASN="GeoLite2-ASN.tar.gz"

if [ -f "/config/GeoIP/GeoLite2-City.mmdb" ]; then
  CURRENT_SHA_CITY=$(sha256sum /config/GeoIP/GeoLite2-City.mmdb | awk '{ print $1 }')
  echo "---------------------------------------------------"
  echo "Updating GeoLite2-City.mmdb"
  echo "Current GeoLite2-City.mmdb SHA256: ${CURRENT_SHA_CITY}"
  if ! wget "${DOWNLOAD_URL_CITY}" -O ${FILE_NAME_CITY} &>/dev/null; then
    echo "Error downloading GeoLite2-City.mmdb"
    echo "---------------------------------------------------"
    exit 1
  else
    echo "Successfully downloaded files."
    echo "Extracting.."
    if ! tar -zxf GeoLite2-City.tar.gz &>/dev/null; then
      echo "Error extracting files."
      echo "---------------------------------------------------"
      exit 1
    else
      NEW_SHA_CITY=$(sha256sum GeoLite2-City_*/GeoLite2-City.mmdb | awk '{ print $1 }')
      echo "Successfully extracted."
      echo "SHA256 of GeoLite2-City.mmdb: ${NEW_SHA_CITY}"
    fi

    if [[ "${CURRENT_SHA_CITY}" != "${NEW_SHA_CITY}" ]]; then
      echo "GeoLite2-City.mmdb SHA mismatch detected. Updating.."
      mv GeoLite2-City_*/GeoLite2-City.mmdb /config/GeoIP/GeoLite2-City.mmdb
      echo "Moved GeoLite2-City.mmdb to /config/GeoIP/.. It is recommended to restart the container."
      echo "---------------------------------------------------"
    else
      echo "No update needed for GeoLite2-City.mmdb"
      echo "---------------------------------------------------"
    fi
  fi
else
  if ! wget "${DOWNLOAD_URL_CITY}" -O ${FILE_NAME_CITY} &>/dev/null; then
    echo "Error downloading GeoLite2-City.mmdb"
    echo "---------------------------------------------------"
    exit 1
  else
    echo "Successfully downloaded files."
    echo "Extracting.."
    if ! tar -zxf GeoLite2-City.tar.gz &>/dev/null; then
      echo "Error extracting files."
      echo "---------------------------------------------------"
      exit 1
    else
      NEW_SHA_CITY=$(sha256sum GeoLite2-City_*/GeoLite2-City.mmdb | awk '{ print $1 }')
      echo "Successfully extracted."
      echo "SHA256 of GeoLite2-City.mmdb: ${NEW_SHA_CITY}"
    fi

    mv GeoLite2-City_*/GeoLite2-City.mmdb /config/GeoIP/GeoLite2-City.mmdb
    echo "Moved GeoLite2-City.mmdb to /config/GeoIP/.. It is recommended to restart the container."
  fi
fi

if [ -f "/config/GeoIP/GeoLite2-ASN.mmdb" ]; then
  CURRENT_SHA_ASN=$(sha256sum /config/GeoIP/GeoLite2-ASN.mmdb | awk '{ print $1 }')

  echo "---------------------------------------------------"
  echo "Current GeoLite2-ASN.mmdb SHA256: ${CURRENT_SHA_ASN}"
  echo "Updating GeoLite2-ASN.mmdb"
  if ! wget "${DOWNLOAD_URL_ASN}" -O ${FILE_NAME_ASN} &>/dev/null; then
    echo "Error downloading GeoLite2-ASN.mmdb"
    echo "---------------------------------------------------"
    exit 1
  else
    echo "Successfully downloaded files."
    echo "Extracting.."
    if ! tar -zxf GeoLite2-ASN.tar.gz &>/dev/null; then
      echo "Error extracting files."
      echo "---------------------------------------------------"
      exit 1
    else
      NEW_SHA_ASN=$(sha256sum GeoLite2-ASN_*/GeoLite2-ASN.mmdb | awk '{ print $1 }')
      echo "Successfully extracted."
      echo "SHA256 of GeoLite2-ASN.mmdb: ${NEW_SHA_ASN}"
    fi

    if [[ "${CURRENT_SHA_ASN}" != "${NEW_SHA_ASN}" ]]; then
      echo "GeoLite2-ASN.mmdb SHA mismatch detected. Updating.."
      mv GeoLite2-ASN_*/GeoLite2-ASN.mmdb /config/GeoIP/GeoLite2-ASN.mmdb
      echo "Moved GeoLite2-ASN.mmdb to /config/GeoIP/.. It is recommended to restart the container."
      echo "---------------------------------------------------"
    else
      echo "No update needed for GeoLite2-ASN.mmdb"
      echo "---------------------------------------------------"
    fi
  fi
else
  if ! wget "${DOWNLOAD_URL_ASN}" -O ${FILE_NAME_ASN} &>/dev/null; then
    echo "Error downloading GeoLite2-ASN.mmdb"
    echo "---------------------------------------------------"
    exit 1
  else
    echo "Successfully downloaded files."
    echo "Extracting.."
    if ! tar -zxf GeoLite2-ASN.tar.gz &>/dev/null; then
      echo "Error extracting files."
      echo "---------------------------------------------------"
      exit 1
    else
      NEW_SHA_ASN=$(sha256sum GeoLite2-ASN_*/GeoLite2-ASN.mmdb | awk '{ print $1 }')
      echo "Successfully extracted."
      echo "SHA256 of GeoLite2-ASN.mmdb: ${NEW_SHA_ASN}"
    fi

    mv GeoLite2-ASN_*/GeoLite2-ASN.mmdb /config/GeoIP/GeoLite2-ASN.mmdb
    echo "Moved GeoLite2-ASN.mmdb to /config/GeoIP/.. It is recommended to restart the container."
  fi
fi
