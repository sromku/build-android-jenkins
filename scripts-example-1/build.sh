#!/bin/bash

# input params
branchName=$1
buildType=$2
storePass=$3
keyAlias=$4
keyPass=$5

# helper method
setProperty() {
	sed -i.bak -e "s/\($1 *= *\).*/\1$2/" ${propertiesFile}
}

propertiesFile='gradle.properties'
chmod +x ${propertiesFile}

# update key properties based on build type
if [ $buildType = 'debug' ]; then
	(setProperty "KEYSTORE" "keystore/debug.keystore")
	(setProperty "STORE_PASSWORD" "123456")
	(setProperty "KEY_ALIAS" "my_alias")
	(setProperty "KEY_PASSWORD" "123456")
elif [ $buildType = 'release' ]; then
	(setProperty "KEYSTORE" "keystore/release.keystore")
	(setProperty "STORE_PASSWORD" "$storePass")
	(setProperty "KEY_ALIAS" "$keyAlias")
	(setProperty "KEY_PASSWORD" "$keyPass")
fi

# clean project
chmod +x gradlew
./gradlew clean --stacktrace

# give access to keystore
chmod +x keystore/debug.keystore
chmod +x keystore/release.keystore

# build
if [ $buildType = 'debug' ]; then
	./gradlew assembleDebug --stacktrace
elif [ $buildType = 'release' ]; then
	./gradlew assembleRelease --stacktrace
fi

# post build
mobileFileName="mobile-$buildType.apk"

# -------------------------------------
### CHECK THAT APK FILE EXISTS
if [ ! -e "mobile/build/outputs/apk/$mobileFileName" ]; then
    echo "ERROR: File not exists: (mobile/build/outputs/apk/$mobileFileName)"
    exit 1
fi

# copy mobile apk
rm -r artifacts/
mkdir artifacts
cp mobile/build/outputs/apk/$mobileFileName artifacts/