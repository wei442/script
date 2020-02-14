#!/bin/bash
echo "build tinyid begin"
cd ../../tinyid/
mvn clean install
echo "build tinyid end"

echo "build open-common begin"
cd ../open-api/open-common
mvn clean install
echo "build open-common begin"

echo "build open-provider-user begin"
cd ../open-provider-user
mvn clean install
echo "build open-provider-user end"

echo "copy open-provider-user begin"
cp target/open-provider-user-0.0.1.jar /home/weiyong/java_dev/open-provider-user/lib
cp src/main/resources/application-dev.properties /home/weiyong/java_dev/open-provider-user/conf
echo "copy open-provider-user end"


