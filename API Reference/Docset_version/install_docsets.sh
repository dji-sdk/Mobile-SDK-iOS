#!/bin/sh
#
# Copyright (c) 2015-present, DJI, Inc. All rights reserved.
#
# This script installs the docsets in the current folder into the user's ~/Library

(
cd "$(dirname "$0")"
DESTINATION="$HOME/Library/Developer/Shared/Documentation/DocSets/"
echo "This script will install the docsets in the current folder into $DESTINATION"
\ls -d *.docset | xargs -I {} cp -R {} $DESTINATION
echo "Installation complete. Please restart Xcode."
break;

)
