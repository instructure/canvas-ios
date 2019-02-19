#  strip-framework.sh
#  Copyright © 2010-2019 PSPDFKit GmbH. All rights reserved.
#
#  THIS SOURCE CODE AND ANY ACCOMPANYING DOCUMENTATION ARE PROTECTED BY INTERNATIONAL COPYRIGHT LAW
#  AND MAY NOT BE RESOLD OR REDISTRIBUTED. USAGE IS BOUND TO THE PSPDFKIT LICENSE AGREEMENT.
#  UNAUTHORIZED REPRODUCTION OR DISTRIBUTION IS SUBJECT TO CIVIL AND CRIMINAL PENALTIES.
#  This notice may not be removed from this file.

function message {
    echo "[PSPDFKit] strip-framework.sh: $1"
}

function codesign {
    message "Code signing $1 using identity \"$EXPANDED_CODE_SIGN_IDENTITY_NAME\""
    /usr/bin/codesign --force --sign "$EXPANDED_CODE_SIGN_IDENTITY" --preserve-metadata=identifier,entitlements "$1"
}

function strip_binary {
    binary="$1"
    archs=$(lipo -info "$binary" | rev | cut -d ':' -f1 | rev)
    stripped_archs=""
    for arch in $archs; do
        if [[ "$VALID_ARCHS" != *"$arch"* ]]; then
            # Remove unneeded slices
            lipo -remove "$arch" -output "$binary" "$binary" || exit 1
            stripped_archs="$stripped_archs $arch"
        fi
    done
    echo "$stripped_archs"
}

function strip_dSYM {
    dSYM="$1"

    stripped_dSYM_archs=$(strip_binary "$dSYM")

    if [[ -n "$stripped_dSYM_archs" ]]; then
        framework=$(basename "$dSYM")
        message "Removed the following architectures from $framework dSYM: $stripped_dSYM_archs"
    fi
}

cd "$BUILT_PRODUCTS_DIR/$FRAMEWORKS_FOLDER_PATH" || exit 1

frameworks=("PSPDFKit" "PSPDFKitUI" "Instant")
input_files=("$SCRIPT_INPUT_FILE_0" "$SCRIPT_INPUT_FILE_1" "$SCRIPT_INPUT_FILE_2")

input_file_count="${#input_files[@]}"
if [ "$SCRIPT_INPUT_FILE_COUNT" -gt "$input_file_count" ]; then
    message "Only $input_file_count dSYM folders as input files allowed"
    exit 1
fi

for framework in "${frameworks[@]}"; do
    framework_folder="$framework.framework"

    if ! [ -d "$framework_folder" ]; then
        continue
    fi

    # It's important to copy/remove the bcsymbolmap files before code signing,
    # otherwise you'll get an "A signed resource has been added, modified, or deleted" error.
    if [ "$ACTION" == "install" ]; then
        for file in strip-framework.sh split-binary.sh combine-binaries.sh strip-bitcode.sh "$framework-armv7" "$framework-arm64" "$framework-iphonesimulator"; do
            if [ -e "$framework_folder/$file" ]; then
                message "Removing $file from embedded $framework_folder"
                rm -f "$framework_folder/$file"
            fi
        done

        # Only copy .bcsymbolmap files if they exist
        if compgen -G "$framework_folder/BCSymbolMaps/*.bcsymbolmap" > /dev/null; then
            message "Copying $framework_folder's .bcsymbolmap files to .xcarchive"
            find "$framework_folder/BCSymbolMaps" -name "*.bcsymbolmap" -type f -exec mv {} "$CONFIGURATION_BUILD_DIR" \;
        fi
    fi

    # Remove *.bcsymbolmap files from framework folder
    rm -rf "$framework_folder/BCSymbolMaps"

    framework_binary="$framework_folder/$framework"
    # No need to strip static libraries
    if [[ $(file "$framework_binary") != *"dynamically linked shared library"* ]]; then
        exit 0
    fi

    stripped_framework_archs=$(strip_binary "$framework_binary")

    if [[ -n "$stripped_framework_archs" ]]; then
        message "Removed the following architectures from $framework framework: $stripped_framework_archs"
        if [ "$CODE_SIGNING_REQUIRED" == "YES" ]; then
            codesign "$framework_binary"
        fi
    fi
done

# Using a "Copy Files" build phase to copy debug symbols and setting the
# `COPY_PHASE_STRIP` build setting to `YES` causes the `strip` command to fail
# with the message "string table not at the end of the file" when processing
# the debug symbols binary. As a workaround we copy the debug symbols within
# this script.
for input_file in "${input_files[@]}"; do
    if [ -n "$input_file" ]; then
        dSYM_path="$input_file"
        dSYM_folder=$(basename "$dSYM_path")
        framework=${dSYM_folder%".framework.dSYM"}

        if [[ "${frameworks[*]}" != *"$framework"* ]]; then
            message "dSYM folder doesn't belong to a PSPDFKit framework: $dSYM_path"
            exit 2
        fi

        dSYM="$dSYM_path/Contents/Resources/DWARF/$framework"
        # Check if dSYM binary exists
        if [[ $(file "$dSYM") != *"dSYM companion file"* ]]; then
            message "dSYM folder doesn't contain binary: $dSYM_path"
            exit 3
        fi

        # Copy debug symbols into products directory if they aren't there already
        if [ ! -d "$BUILT_PRODUCTS_DIR/$dSYM_folder" ]; then
            cp -rf "$dSYM_path" "$BUILT_PRODUCTS_DIR"
            message "Copied $dSYM_folder into products directory"
        fi

        strip_dSYM "$BUILT_PRODUCTS_DIR/$dSYM_folder/Contents/Resources/DWARF/$framework"
    fi
done

if [ "$SCRIPT_INPUT_FILE_COUNT" -lt "$input_file_count" ]; then
    for framework in "${frameworks[@]}"; do
        # Check if debug symbols were manually copied into products directory
        dSYM_folder="$BUILT_PRODUCTS_DIR/$framework.framework.dSYM"
        dSYM="$dSYM_folder/Contents/Resources/DWARF/$framework"
        # Check if dSYM binary exists
        if [[ $(file "$dSYM") == *"dSYM companion file"* ]]; then
            strip_dSYM "$dSYM"
        fi
    done
fi
