#!/bin/bash

# Converter videos to WebM-VP9
# ------------------------------
function vtovp9() {

    if [[ -f "$1" && -x "$(command -v ffmpeg)" ]] ; then
        case "$1" in
            *.asf)  ffmpeg -i "$1" -c:v libvpx-vp9 -crf 33 -threads 8 -b:v 0 -b:a 128k -c:a libopus -map_metadata -1 "${1%.asf}".webm  ;;
            *.avi)  ffmpeg -i "$1" -c:v libvpx-vp9 -crf 33 -threads 8 -b:v 0 -b:a 128k -c:a libopus -map_metadata -1 "${1%.avi}".webm  ;;
            *.flv)  ffmpeg -i "$1" -c:v libvpx-vp9 -crf 33 -threads 8 -b:v 0 -b:a 128k -c:a libopus -map_metadata -1 "${1%.flv}".webm  ;;
            *.mkv)  ffmpeg -i "$1" -c:v libvpx-vp9 -crf 33 -threads 8 -b:v 0 -b:a 128k -c:a libopus -map_metadata -1 "${1%.mkv}".webm  ;;
            *.mov)  ffmpeg -i "$1" -c:v libvpx-vp9 -crf 33 -threads 8 -b:v 0 -b:a 128k -c:a libopus -map_metadata -1 "${1%.mov}".webm  ;;
            *.mp4)  ffmpeg -i "$1" -c:v libvpx-vp9 -crf 33 -threads 8 -b:v 0 -b:a 128k -c:a libopus -map_metadata -1 "${1%.mp4}".webm  ;;
            *.mpg)  ffmpeg -i "$1" -c:v libvpx-vp9 -crf 33 -threads 8 -b:v 0 -b:a 128k -c:a libopus -map_metadata -1 "${1%.mpg}".webm  ;;
            *.ogv)  ffmpeg -i "$1" -c:v libvpx-vp9 -crf 33 -threads 8 -b:v 0 -b:a 128k -c:a libopus -map_metadata -1 "${1%.ogv}".webm  ;;
            *.webm) ffmpeg -i "$1" -c:v libvpx-vp9 -crf 33 -threads 8 -b:v 0 -b:a 128k -c:a libopus -map_metadata -1 "${1%.webm}".webm ;;
            *.wmv)  ffmpeg -i "$1" -c:v libvpx-vp9 -crf 33 -threads 8 -b:v 0 -b:a 128k -c:a libopus -map_metadata -1 "${1%.wmv}".webm  ;;
            *)      msg_err "El formato de '$1' no esta listado :(" \
                            "The format of '$1' is not listed :("
                    return 1 ;;
        esac
    else
        msg_err "Error, este no es un archivo de vídeo válido" \
                "Error, this is not a valid video file"
        return 1
    fi

}

# Converter all videos to WebM-VP9
# --------------------------------
function alltovp9() {

    if [[ -x "$(command -v rename)" ]]; then
        # lowercase
        for j in ASF AVI FLV MKV MOV MP4 MPG M2TS OGV VOB WMV ;
        do
            rename ."$j" ."${j,,}" -- *."$j" 2&> /dev/null
        done
    fi

    sleep 1

    if [[ -x "$(command -v ffmpeg)" ]]; then
        for FILE_NAME in *
        do
            if [[ -f "$FILE_NAME" ]]; then
                case "$FILE_NAME" in
                    *.asf)  ffmpeg -i "$FILE_NAME" -c:v libvpx-vp9 -crf 33 -threads 8 -b:v 0 -b:a 128k -c:a libopus -map_metadata -1 "${FILE_NAME%.asf}".webm  ;;
                    *.avi)  ffmpeg -i "$FILE_NAME" -c:v libvpx-vp9 -crf 33 -threads 8 -b:v 0 -b:a 128k -c:a libopus -map_metadata -1 "${FILE_NAME%.avi}".webm  ;;
                    *.flv)  ffmpeg -i "$FILE_NAME" -c:v libvpx-vp9 -crf 33 -threads 8 -b:v 0 -b:a 128k -c:a libopus -map_metadata -1 "${FILE_NAME%.flv}".webm  ;;
                    *.mkv)  ffmpeg -i "$FILE_NAME" -c:v libvpx-vp9 -crf 33 -threads 8 -b:v 0 -b:a 128k -c:a libopus -map_metadata -1 "${FILE_NAME%.mkv}".webm  ;;
                    *.mov)  ffmpeg -i "$FILE_NAME" -c:v libvpx-vp9 -crf 33 -threads 8 -b:v 0 -b:a 128k -c:a libopus -map_metadata -1 "${FILE_NAME%.mov}".webm  ;;
                    *.mp4)  ffmpeg -i "$FILE_NAME" -c:v libvpx-vp9 -crf 33 -threads 8 -b:v 0 -b:a 128k -c:a libopus -map_metadata -1 "${FILE_NAME%.mp4}".webm  ;;
                    *.mpg)  ffmpeg -i "$FILE_NAME" -c:v libvpx-vp9 -crf 33 -threads 8 -b:v 0 -b:a 128k -c:a libopus -map_metadata -1 "${FILE_NAME%.mpg}".webm  ;;
                    *.m2ts) ffmpeg -i "$FILE_NAME" -c:v libvpx-vp9 -crf 33 -threads 8 -b:v 0 -b:a 128k -c:a libopus -map_metadata -1 "${FILE_NAME%.m2ts}".webm ;;
                    *.ogv)  ffmpeg -i "$FILE_NAME" -c:v libvpx-vp9 -crf 33 -threads 8 -b:v 0 -b:a 128k -c:a libopus -map_metadata -1 "${FILE_NAME%.ogv}".webm  ;;
                    *.vob)  ffmpeg -i "$FILE_NAME" -c:v libvpx-vp9 -crf 33 -threads 8 -b:v 0 -b:a 128k -c:a libopus -map_metadata -1 "${FILE_NAME%.vob}".webm  ;;
                    *.wmv)  ffmpeg -i "$FILE_NAME" -c:v libvpx-vp9 -crf 33 -threads 8 -b:v 0 -b:a 128k -c:a libopus -map_metadata -1 "${FILE_NAME%.wmv}".webm  ;;
                    # Warnnig messages
                    *.webm) printf '\e[1;36m%s\e[m\n' "Saltando '$FILE_NAME', ya está en formato WebM" ;;
                    *)      printf '\e[1;36m%s\e[m\n' "El formato de '$FILE_NAME' no esta listado" ;;
                esac
            fi
        done
    else
        msg_err "No esta instalado ffmpeg" \
                "ffmpeg is not installed"
        return 1
    fi
}
