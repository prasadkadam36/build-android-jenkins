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
# -------------------------- TESTS & LINT--------------------------
# -----------------------------------------------------------------
./gradlew lint

# -----------------------------------------------------------------
# -------------------------- POST BUILD ---------------------------
# -----------------------------------------------------------------
apkFileName="app-$buildType.apk"
rm -r artifacts/
rm -r report/
mkdir artifacts
mkdir report

# copy apk to artifacts
if [ ! -e "app/build/outputs/apk/$buildType/$apkFileName" ]; then
    echo "ERROR: File not exists: (app/build/outputs/apk/$buildType/$apkFileName)"
    exit 1
fi
cp app/build/outputs/apk/$buildType/$apkFileName artifacts/

# copy lint results
if [ ! -e "app/build/reports/lint-results.xml" ]; then
	echo "ERROR: File not exists: (app/build/reports/lint-results.xml)"
	exit 1
fi
cp app/build/reports/lint-results.xml report/

