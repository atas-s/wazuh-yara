#!/bin/bash
# Wazuh - Yara active response
# Wazuh - Yara active response
# Copyright (C) 2015-2022, Wazuh Inc. 
# Wazuh - Yara active response (Optimized by Gemini & Antropic

#------------------------- Gather parameters -------------------------#
# Extra arguments
read INPUT_JSON
YARA_PATH=$(echo $INPUT_JSON | jq -r .parameters.extra_args[1])
YARA_RULES=$(echo $INPUT_JSON | jq -r .parameters.extra_args[3])
FILENAME=$(echo $INPUT_JSON | jq -r .parameters.alert.syscheck.path)
LOG_FILE="logs/active-responses.log"

#----------------------- Parametre Kontrolü -----------------------#
if [[ ! $YARA_PATH ]] || [[ ! $YARA_RULES ]] || [[ ! $FILENAME ]]; then
    echo "wazuh-yara: ERROR - Mandatory parameters missing." >> ${LOG_FILE}
    exit 1
fi

#------------------- Dosya Yazılana Kadar Bekle ------------------#
# wget -O gibi durumlar için 0-byte dosyanın dolmasını bekler
max_attempts=10
attempts=0
actual_size=$(stat -c %s "${FILENAME}" 2>/dev/null || echo 0)

while [ "$actual_size" -eq 0 ] && [ $attempts -lt $max_attempts ]; do
    sleep 1
    actual_size=$(stat -c %s "${FILENAME}" 2>/dev/null || echo 0)
    attempts=$((attempts + 1))
done

# Boyut sabitlenene kadar bekleme döngüsü
size=-1
while [ "$size" -ne "$actual_size" ]; do
    sleep 1
    size=$actual_size
    actual_size=$(stat -c %s "${FILENAME}" 2>/dev/null || echo 0)
done

#------------------------- Debounce (Kilit) -----------------------#
LOCK_DIR="/tmp/wazuh-yara-locks"
mkdir -p "$LOCK_DIR"
LOCK_FILE="$LOCK_DIR/$(echo "$FILENAME" | md5sum | cut -d' ' -f1).lock"

if [ -f "$LOCK_FILE" ]; then
    LOCK_AGE=$(( $(date +%s) - $(stat -c %Y "$LOCK_FILE") ))
    # Eğer dosya içeriği hala 0 ise kilidi önemseme (tekrar tara)
    if [ "$LOCK_AGE" -lt 20 ] && [ "$actual_size" -gt 0 ]; then
        exit 0
    fi
fi

# Kilidi güncelle veya oluştur
touch "$LOCK_FILE"

#------------------------- YARA Tarama --------------------------#
yara_output="$("${YARA_PATH}"/yara -w -r "$YARA_RULES" "$FILENAME" 2>/dev/null)"

if [[ $yara_output != "" ]]; then
    while read -r line; do
        echo "wazuh-yara: INFO - Scan result: $line" >> ${LOG_FILE}
    done <<< "$yara_output"
fi

exit 0;
