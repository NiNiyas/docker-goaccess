#!/bin/bash

DOWNLOAD_URL_CITY="https://download.maxmind.com/app/geoip_download?edition_id=GeoLite2-City&license_key=$MAXMIND_LICENSE_KEY&suffix=tar.gz"
DOWNLOAD_URL_ASN="https://download.maxmind.com/app/geoip_download?edition_id=GeoLite2-ASN&license_key=$MAXMIND_LICENSE_KEY&suffix=tar.gz"
FILE_NAME_CITY="GeoLite2-City.tar.gz"
FILE_NAME_ASN="GeoLite2-ASN.tar.gz"

TEMP_FOLDER="/tmp/geoip_temp"
mkdir -p "${TEMP_FOLDER}"

if [ -f "/config/geoip/GeoLite2-City.mmdb" ]; then
  CURRENT_SHA_CITY=$(sha256sum /config/geoip/GeoLite2-City.mmdb | awk '{ print $1 }')
  echo "---------------------------------------------------"
  echo "Updating GeoLite2-City.mmdb"
  echo "Current GeoLite2-City.mmdb SHA256: ${CURRENT_SHA_CITY}"
  if ! wget "${DOWNLOAD_URL_CITY}" -O "/config/geoip/${FILE_NAME_CITY}" &>/dev/null; then
    echo "Error downloading GeoLite2-City.mmdb"
    echo "---------------------------------------------------"
  else
    echo "Successfully downloaded files."
    echo "Extracting.."
    if ! tar -zxf "/config/geoip/${FILE_NAME_CITY}" -C "${TEMP_FOLDER}" &>/dev/null; then
      echo "Error extracting files."
      echo "---------------------------------------------------"
    else
      mmdb_file=$(find "$TEMP_FOLDER" -name "GeoLite2-City.mmdb" -type f)
      NEW_SHA_CITY=$(sha256sum "${mmdb_file}" | awk '{ print $1 }')
      echo "Successfully extracted."
      echo "SHA256 of GeoLite2-City.mmdb: ${NEW_SHA_CITY}"
    fi

    if [[ "${CURRENT_SHA_CITY}" != "${NEW_SHA_CITY}" ]]; then
      echo "GeoLite2-City.mmdb SHA mismatch detected. Updating.."
      mv "${mmdb_file}" /config/geoip/GeoLite2-City.mmdb
      echo "Successfully downloaded GeoLite2-City.mmdb to /config/geoip/. It is recommended to restart the container."
      echo "---------------------------------------------------"
    else
      echo "No update needed for GeoLite2-City.mmdb"
      echo "---------------------------------------------------"
    fi
  fi
else
  echo "---------------------------------------------------"
  echo "Downloading GeoLite2-City.mmdb"
  if ! wget "${DOWNLOAD_URL_CITY}" -O "/config/geoip/${FILE_NAME_CITY}" &>/dev/null; then
    echo "Error downloading GeoLite2-City.mmdb"
    echo "---------------------------------------------------"
  else
    echo "Successfully downloaded files."
    echo "Extracting.."
    if ! tar -zxf "/config/geoip/${FILE_NAME_CITY}" -C "${TEMP_FOLDER}" &>/dev/null; then
      echo "Error extracting files."
      echo "---------------------------------------------------"
    else
      mmdb_file=$(find "$TEMP_FOLDER" -name "GeoLite2-City.mmdb" -type f)
      NEW_SHA_CITY=$(sha256sum "${mmdb_file}" | awk '{ print $1 }')
      echo "Successfully extracted."
      echo "SHA256 of GeoLite2-City.mmdb: ${NEW_SHA_CITY}"
    fi

    mv "${mmdb_file}" /config/geoip/GeoLite2-City.mmdb
    echo "Successfully downloaded GeoLite2-City.mmdb to /config/geoip/. It is recommended to restart the container."
    echo "---------------------------------------------------"
  fi
fi

if [ -f "/config/geoip/GeoLite2-ASN.mmdb" ]; then
  CURRENT_SHA_ASN=$(sha256sum /config/geoip/GeoLite2-ASN.mmdb | awk '{ print $1 }')
  echo "---------------------------------------------------"
  echo "Current GeoLite2-ASN.mmdb SHA256: ${CURRENT_SHA_ASN}"
  echo "Updating GeoLite2-ASN.mmdb"
  if ! wget "${DOWNLOAD_URL_ASN}" -O "/config/geoip/${FILE_NAME_ASN}" &>/dev/null; then
    echo "Error downloading GeoLite2-ASN.mmdb"
    echo "---------------------------------------------------"
  else
    echo "Successfully downloaded files."
    echo "Extracting.."
    if ! tar -zxf "/config/geoip/${FILE_NAME_ASN}" -C "${TEMP_FOLDER}" &>/dev/null; then
      echo "Error extracting files."
      echo "---------------------------------------------------"
    else
      asn_mmdb_file=$(find "$TEMP_FOLDER" -name "GeoLite2-ASN.mmdb" -type f)
      NEW_SHA_ASN=$(sha256sum "${asn_mmdb_file}" | awk '{ print $1 }')
      echo "Successfully extracted."
      echo "SHA256 of GeoLite2-ASN.mmdb: ${NEW_SHA_ASN}"
    fi

    if [[ "${CURRENT_SHA_ASN}" != "${NEW_SHA_ASN}" ]]; then
      echo "GeoLite2-ASN.mmdb SHA mismatch detected. Updating.."
      mv "${asn_mmdb_file}" /config/geoip/GeoLite2-ASN.mmdb
      echo "Successfully downloaded GeoLite2-ASN.mmdb to /config/geoip/. It is recommended to restart the container."
      echo "---------------------------------------------------"
    else
      echo "No update needed for GeoLite2-ASN.mmdb"
      echo "---------------------------------------------------"
    fi
  fi
else
  echo "---------------------------------------------------"
  echo "Downloading GeoLite2-ASN.mmdb"
  if ! wget "${DOWNLOAD_URL_ASN}" -O "/config/geoip/${FILE_NAME_ASN}" &>/dev/null; then
    echo "Error downloading GeoLite2-ASN.mmdb"
    echo "---------------------------------------------------"
  else
    echo "Successfully downloaded files."
    echo "Extracting.."
    if ! tar -zxf "/config/geoip/${FILE_NAME_ASN}" -C "${TEMP_FOLDER}" &>/dev/null; then
      echo "Error extracting files."
      echo "---------------------------------------------------"
    else
      asn_mmdb_file=$(find "$TEMP_FOLDER" -name "GeoLite2-ASN.mmdb" -type f)
      NEW_SHA_ASN=$(sha256sum "${asn_mmdb_file}" | awk '{ print $1 }')
      echo "Successfully extracted."
      echo "SHA256 of GeoLite2-ASN.mmdb: ${NEW_SHA_ASN}"
    fi

    mv "${asn_mmdb_file}" /config/geoip/GeoLite2-ASN.mmdb
    echo "Successfully downloaded GeoLite2-ASN.mmdb to /config/geoip/. It is recommended to restart the container."
    echo "---------------------------------------------------"
  fi
fi

rm -rf ${TEMP_FOLDER}
rm "/config/geoip/${FILE_NAME_CITY}"
rm "/config/geoip/${FILE_NAME_ASN}"
