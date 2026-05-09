#!/bin/bash

TEMP_FOLDER="/tmp/geoip_temp"

update_db() {
  local edition_id="$1"
  local file_name="$2"
  local db_file="$3"
  
  local download_url="https://download.maxmind.com/app/geoip_download?edition_id=${edition_id}&license_key=${MAXMIND_LICENSE_KEY}&suffix=tar.gz"
  local tar_file="/config/geoip/${file_name}"
  local current_sha=""
  local is_update=false
  
  echo "[${edition_id}] Checking for updates..."

  if [ -f "/config/geoip/${db_file}" ]; then
    current_sha=$(sha256sum "/config/geoip/${db_file}" | awk '{ print $1 }')
    is_update=true
  fi

  if ! wget "${download_url}" -O "${tar_file}" &>/dev/null; then
    echo "[${edition_id}] Error downloading database."
    return 1
  fi

  rm -rf "${TEMP_FOLDER}"
  mkdir -p "${TEMP_FOLDER}"

  if ! tar -zxf "${tar_file}" -C "${TEMP_FOLDER}" &>/dev/null; then
    echo "[${edition_id}] Error extracting files."
    rm -f "${tar_file}"
    return 1
  fi

  local extracted_file
  extracted_file=$(find "${TEMP_FOLDER}" -name "${db_file}" -type f 2>/dev/null)

  if [ -z "${extracted_file}" ] || [ ! -f "${extracted_file}" ]; then
    echo "[${edition_id}] Error: ${db_file} not found in extracted archive."
    rm -f "${tar_file}"
    return 1
  fi

  local new_sha
  new_sha=$(sha256sum "${extracted_file}" | awk '{ print $1 }')

  if [ "$is_update" = true ] && [ "${current_sha}" = "${new_sha}" ]; then
    echo "[${edition_id}] No update needed (Checksum: ${new_sha:0:8})"
  else
    mv "${extracted_file}" "/config/geoip/${db_file}"
    if [ "$is_update" = true ]; then
        echo "[${edition_id}] Update successful. New Checksum: ${new_sha:0:8}"
    else
        echo "[${edition_id}] Download successful. Checksum: ${new_sha:0:8}"
    fi
  fi

  rm -f "${tar_file}"
  return 0
}

update_db "GeoLite2-City" "GeoLite2-City.tar.gz" "GeoLite2-City.mmdb"
update_db "GeoLite2-ASN" "GeoLite2-ASN.tar.gz" "GeoLite2-ASN.mmdb"

rm -rf "${TEMP_FOLDER}"
