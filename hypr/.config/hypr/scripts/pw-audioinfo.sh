#!/usr/bin/env bash
# pw-audioinfo.sh — outputs current PipeWire audio stats as JSON

get_bit_depth() {
    case "$1" in
        S16_LE|S16_BE|U16_LE|U16_BE) echo "16" ;;
        S24_LE|S24_BE|U24_LE|U24_BE) echo "24" ;;
        S24_3LE|S24_3BE)             echo "24" ;;
        S32_LE|S32_BE|U32_LE|U32_BE) echo "32" ;;
        FLOAT_LE|FLOAT_BE)           echo "32" ;;
        FLOAT64_LE|FLOAT64_BE)       echo "64" ;;
        DSD*)                        echo "DSD" ;;
        *)                           echo "?" ;;
    esac
}

format_rate() {
    case "$1" in
        44100)  echo "44.1kHz" ;;
        48000)  echo "48kHz" ;;
        88200)  echo "88.2kHz" ;;
        96000)  echo "96kHz" ;;
        176400) echo "176.4kHz" ;;
        192000) echo "192kHz" ;;
        352800) echo "352.8kHz" ;;
        384000) echo "384kHz" ;;
        *)      echo "${1}Hz" ;;
    esac
}

# Default sink name
DEFAULT_SINK=$(pactl info 2>/dev/null | awk '/^Default Sink:/{print $NF}')

if [[ -z "$DEFAULT_SINK" ]]; then
    echo '{"active":false,"device":"--","rate":"--","bits":"--","format":"--"}'
    exit 0
fi

# Escape dots for awk regex
SINK_ESCAPED="${DEFAULT_SINK//./\\.}"

# Get ALSA card number directly from pactl properties — no string matching needed
CARD_NUM=$(pactl list sinks 2>/dev/null | awk "
    /^\tName: ${SINK_ESCAPED}\$/ { found=1 }
    found && /alsa\.card = /     { match(\$0, /\"([0-9]+)\"/, a); print a[1]; exit }
")

# Get human-readable device name from Description field
DEVICE_DESC=$(pactl list sinks 2>/dev/null | awk "
    /^\tName: ${SINK_ESCAPED}\$/ { found=1 }
    found && /^\tDescription:/   { sub(/^\tDescription: /, \"\"); print; exit }
" | cut -c1-24)

[[ -z "$DEVICE_DESC" ]] && DEVICE_DESC="${DEFAULT_SINK##*.}"

if [[ -z "$CARD_NUM" ]]; then
    echo "{\"active\":false,\"device\":\"$DEVICE_DESC\",\"rate\":\"--\",\"bits\":\"--\",\"format\":\"--\"}"
    exit 0
fi

# Read hw_params — first open PCM playback sub-device wins
HW_PARAMS=""
for pcm in pcm0p pcm1p pcm2p pcm3p; do
    path="/proc/asound/card${CARD_NUM}/${pcm}/sub0/hw_params"
    [[ -f "$path" ]] || continue
    content=$(< "$path")
    if [[ "$content" != "closed" && -n "$content" ]]; then
        HW_PARAMS="$content"
        break
    fi
done

if [[ -z "$HW_PARAMS" ]]; then
    echo "{\"active\":false,\"device\":\"$DEVICE_DESC\",\"rate\":\"--\",\"bits\":\"--\",\"format\":\"--\"}"
    exit 0
fi

RAW_FORMAT=$(awk '/^format:/{print $2}' <<< "$HW_PARAMS")
RAW_RATE=$(awk '/^rate:/{print $2}' <<< "$HW_PARAMS")

BITS=$(get_bit_depth "$RAW_FORMAT")
RATE=$(format_rate "$RAW_RATE")

echo "{\"active\":true,\"device\":\"$DEVICE_DESC\",\"rate\":\"$RATE\",\"bits\":\"${BITS}bit\",\"format\":\"$RAW_FORMAT\"}"
