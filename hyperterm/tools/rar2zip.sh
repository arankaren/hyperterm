#!/bin/bash
#
# rar2zip conversion script
#
# Usage: rar2zip file [file ...]
# Example: rar2zip file.rar

function rar2zip() {

    echo "Converting RARs to ZIPs"

    # Use RAM disk for temporary files.
    WORKDIR="/dev/shm/"

    for INFILE in "$@"; do
        # Absolute path to old file
        OLDFILE=$(realpath "${INFILE}")

        # Get the file name without the extension
        BASENAME=$(basename "${OLDFILE%.*}")

        # Path for the file. The ".zip" file will be written there.
        DIRNAME=$(dirname "$OLDFILE")

        # Name of the .zip file
        NEWNAME="${DIRNAME}/$BASENAME.zip"

        if [ ! -e "${NEWNAME}" ]; then
            # Set name for the temp dir. This directory will be created under WORKDIR
            TEMPDIR=$(mktemp -p "$WORKDIR" -d)

            # Create a temporary folder for unRARed files
            echo "Extracting $OLDFILE"

            unar "$OLDFILE" -o "${TEMPDIR}/"

            # Zip the files with maximum compression
            7z a -tzip -mx=9 "$NEWNAME" "${TEMPDIR}/*"
            # Alternative. MUCH SLOWER, but better compression
            # 7z a -mm=Deflate -mfb=258 -mpass=15 -r "$NEWNAME" *

            # Preserve file modification time
            touch -r "$OLDFILE" "$NEWNAME"

            # Delete the temporary directory
            rm -r "$TEMPDIR"

            # OPTIONAL. Safe-remove the old file
            # Restore from "$HOME/.local/share/Trash"
            gio trash "$OLDFILE"
            echo "${OLDFILE}: A backup was made on $HOME/.local/share/Trash"
        else
            echo "${NEWNAME}: File exists!"
        fi
    done

    echo "Conversion Done"
}
