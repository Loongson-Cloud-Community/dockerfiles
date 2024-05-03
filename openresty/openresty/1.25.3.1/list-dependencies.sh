#!/bin/sh -e

##
## @fn list-dependencies.sh
##
## Lists the Debian/Ubuntu package names for all library dependencies of the
## given binaries. Each package is only listed once, even if multiple binaries
## provided by the same package are given.
##
## @param ...
##     The full paths to all binaries being checked.
##

while [ -n "$1" ]; do

    # For all non-Guacamole library dependencies
    ldd "$1" | grep -v "${PREFIX_DIR}" | awk '/=>/{print $(NF-1)}' \
        | while read LIBRARY; do

        # In some cases, the library that's linked against is a hard link
        # to the file that's managed by the package, which dpkg doesn't understand.
        # Searching by */basename ensures the package will be found in these cases.
        LIBRARY_BASENAME=$(basename "$LIBRARY")

        # Determine the Debian package which is associated with that
        # library, if any
        dpkg-query -S "*/$LIBRARY_BASENAME" || true

    done

    # Next binary
    shift

done | cut -f1 -d: | sort -u