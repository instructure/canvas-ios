#!/bin/sh

#  strip-bitcode.sh
#  Copyright © 2016-2019 PSPDFKit GmbH. All rights reserved.
#
#  THIS SOURCE CODE AND ANY ACCOMPANYING DOCUMENTATION ARE PROTECTED BY INTERNATIONAL COPYRIGHT LAW
#  AND MAY NOT BE RESOLD OR REDISTRIBUTED. USAGE IS BOUND TO THE PSPDFKIT LICENSE AGREEMENT.
#  UNAUTHORIZED REPRODUCTION OR DISTRIBUTION IS SUBJECT TO CIVIL AND CRIMINAL PENALTIES.
#  This notice may not be removed from this file.

# For more information about bitcode see https://pspdfkit.com/guides/ios/current/faq/bitcode

set -e

framework_folder=$(dirname "$0")
framework_binary="$framework_folder/PSPDFKit"

if [ ! -e "$framework_binary" ]; then
  echo "No PSPDFKit binary found"
  exit 1
fi

xcrun bitcode_strip -r "$framework_binary" -o "$framework_binary"
echo "Removed bitcode from $framework_binary"

bcsymbolmaps_folder="$framework_folder/BCSymbolMaps"

if [ -d "$bcsymbolmaps_folder" ]; then
  rm -rf "$bcsymbolmaps_folder"
  echo "Removed bcsymbolmaps"
fi

exit 0
