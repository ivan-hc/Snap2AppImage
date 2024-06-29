#!/bin/sh

APP=SAMPLE

# TEMPORARY DIRECTORY
mkdir -p tmp
cd ./tmp || exit 1

# WGET VERSION USAGE
_wget_version_usage() {
	if wget --version | head -1 | grep -q ' 1.'; then
		wget -q --show-progress "$@"
	else
		wget "$@"
	fi
}

# DOWNLOAD APPIMAGETOOL
if ! test -f ./appimagetool; then
	_wget_version_usage "$(wget -q https://api.github.com/repos/probonopd/go-appimage/releases -O - | sed 's/"/ /g; s/ /\n/g' | grep -o 'https.*continuous.*tool.*86_64.*mage$')" -O appimagetool
	chmod a+x ./appimagetool
fi

# DOWNLOAD THE SNAP PACKAGE
if ! test -f ./*.snap; then
	_wget_version_usage "$(curl -H 'Snap-Device-Series: 16' http://api.snapcraft.io/v2/snaps/info/"$APP" --silent | sed 's/[()",{} ]/\n/g' | grep "^http" | head -1)"
fi

# EXTRACT THE SNAP PACKAGE
if ! test -d ./squashfs-root; then
	unsquashfs -f ./*.snap
fi

# FIND PACKAGE VERSION
VERSION=$(cat $(find . -name snapcraft.yaml | head -1) | grep "^version" | head -1 | cut -c 10- | sed 's/"//g; s/ /-/g')

# CREATE THE APPDIR AND COMPILE THE APPIMAGE
mkdir -p "$APP".AppDir
rm -Rf ./"$APP".AppDir/*

# FIND THE .DESKTOP FILE AND REPLACE THE "ICON" ENTRY
cp -r "$(find . -name "$APP".desktop | head -1)" ./"$APP".AppDir/
sed -i "s/^Icon=.*/Icon=$APP/g" ./"$APP".AppDir/*.desktop

# FIND THE APPNAME
APPNAME="$(cat ./"$APP".AppDir/*.desktop | grep '^Name=' | head -1 | cut -c 6- | sed 's/ /-/g')"

# FIND THE ICON
cp -r "$(find . -name *.png | grep -i "$APP" | sort | head -1)" ./"$APP".AppDir/"$APP".png 2> /dev/null
cp -r "$(find . -name *.svg | grep -i "$APP" | sort | head -1)" ./"$APP".AppDir/"$APP".svg 2> /dev/null

# IMPORT COMMON LINUX DIRECTORIES
if test -d ./squashfs-root/etc; then cp -r ./squashfs-root/etc ./"$APP".AppDir/; fi
if test -d ./squashfs-root/lib; then cp -r ./squashfs-root/lib* ./"$APP".AppDir/; fi
if test -d ./squashfs-root/usr; then cp -r ./squashfs-root/usr ./"$APP".AppDir/; fi

# APPRUN
cat >> ./"$APP".AppDir/AppRun << 'EOF'
#!/bin/sh
HERE="$(dirname "$(readlink -f "${0}")")"
export UNION_PRELOAD=/:"${HERE}"
export LD_LIBRARY_PATH="${HERE}"/usr/lib/:"${HERE}"/usr/lib/i386-linux-gnu/:"${HERE}"/usr/lib/x86_64-linux-gnu/:"${HERE}"/lib/:"${HERE}"/lib/i386-linux-gnu/:"${HERE}"/lib/x86_64-linux-gnu/:"${LD_LIBRARY_PATH}"
export PATH="${HERE}"/usr/bin/:"${HERE}"/usr/sbin/:"${HERE}"/usr/games/:"${HERE}"/bin/:"${HERE}"/sbin/:"${PATH}"
export PYTHONPATH="${HERE}"/usr/share/pyshared/:"${HERE}"/usr/lib/python*/:"${PYTHONPATH}"
export PYTHONHOME="${HERE}"/usr/:"${HERE}"/usr/lib/python*/
export XDG_DATA_DIRS="${HERE}"/usr/share/:"${XDG_DATA_DIRS}"
export PERLLIB="${HERE}"/usr/share/perl5/:"${HERE}"/usr/lib/perl5/:"${PERLLIB}"
export GSETTINGS_SCHEMA_DIR="${HERE}"/usr/share/glib-2.0/schemas/:"${GSETTINGS_SCHEMA_DIR}"
export QT_PLUGIN_PATH="${HERE}"/usr/lib/qt4/plugins/:"${HERE}"/usr/lib/i386-linux-gnu/qt4/plugins/:"${HERE}"/usr/lib/x86_64-linux-gnu/qt4/plugins/:"${HERE}"/usr/lib32/qt4/plugins/:"${HERE}"/usr/lib64/qt4/plugins/:"${HERE}"/usr/lib/qt5/plugins/:"${HERE}"/usr/lib/i386-linux-gnu/qt5/plugins/:"${HERE}"/usr/lib/x86_64-linux-gnu/qt5/plugins/:"${HERE}"/usr/lib32/qt5/plugins/:"${HERE}"/usr/lib64/qt5/plugins/:"${QT_PLUGIN_PATH}"
EXEC=$(grep -e '^Exec=.*' "${HERE}"/*.desktop | head -n 1 | cut -d "=" -f 2- | sed -e 's|%.||g')
exec ${EXEC} "$@"
EOF
chmod a+x ./"$APP".AppDir/AppRun

# CONVERT THE APPDIR INTO AN APPIMAGE
ARCH=x86_64 VERSION=$(./appimagetool -v | grep -o '[[:digit:]]*') ./appimagetool -s ./"$APP".AppDir
cd ..
mv ./tmp/*.AppImage ./"$APPNAME"-"$VERSION"-x86_64.AppImage
