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

# -----------------------------------------------------------------
# ------------------------------ BUILD ----------------------------
# -----------------------------------------------------------------
propertiesFile='gradle.properties'
chmod +x ${propertiesFile}

# update key properties based on build type
if [ $buildType = 'debug' ]; then
	(setProperty "KEYSTORE" "debug.keystore")
	(setProperty "STORE_PASSWORD" "123456")
	(setProperty "KEY_ALIAS" "my_alias")
	(setProperty "KEY_PASSWORD" "123456")
elif [ $buildType = 'release' ]; then
	(setProperty "KEYSTORE" "release.keystore")
	(setProperty "STORE_PASSWORD" "$storePass")
	(setProperty "KEY_ALIAS" "$keyAlias")
	(setProperty "KEY_PASSWORD" "$keyPass")
fi

# clean project
chmod +x gradlew
./gradlew clean --stacktrace

# build
if [ $buildType = 'debug' ]; then
	./gradlew assembleDebug --stacktrace
elif [ $buildType = 'release' ]; then
	./gradlew assembleRelease --stacktrace
fi

# -----------------------------------------------------------------
# -------------------------- POST BUILD ---------------------------
# -----------------------------------------------------------------
apkFileName="app-$buildType.apk"
rm -r artifacts/
mkdir artifacts

# copy apk to artifacts
if [ ! -e "app/build/outputs/apk/$buildType/$apkFileName" ]; then
    echo "ERROR: File not exists: (app/build/outputs/apk/$buildType/$apkFileName)"
    exit 1
fi
cp app/build/outputs/apk/$buildType/$apkFileName artifacts/

cat << "EOF"

             ,
         (`.  : \               __..----..__
          `.`.| |:          _,-':::''' '  `:`-._
            `.:\||       _,':::::'         `::::`-.
              \\`|    _,':::::::'     `:.     `':::`.
               ;` `-''  `::::::.                  `::\
            ,-'      .::'  `:::::.         `::..    `:\
          ,' /_) -.            `::.           `:.     |
        ,'.:     `    `:.        `:.     .::.          \
   __,-'   ___,..-''-.  `:.        `.   /::::.         |
  |):'_,--'           `.    `::..       |::::::.      ::\
   `-'                 |`--.:_::::|_____\::::::::.__  ::|
                       |   _/|::::|      \::::::|::/\  :|
                       /:./  |:::/        \__:::):/  \  :\
                     ,'::'  /:::|        ,'::::/_/    `. ``-.__
                    ''''   (//|/\      ,';':,-'         `-.__  `'--..__
                                                             `''---::::'

EOF