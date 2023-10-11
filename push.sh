#!/bin/bash

USERNAME="pradip-wincy"
TOKEN="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"  # Consider using environment variables or some secure method to store this
REPO_OWNER="Rakbank-DEH-Onboarding"
REPO_NAME="RetailOnboarding-AccMS"
GROUP_ID="com.rakbank.infosys.lib"
FILES_DIR="/Users/pradeep/Documents/DEH-Libs-Publish/libs"
ARTIFACT_ID="pd-gen"
VERSION="1111"

for file in "$FILES_DIR"/*.jar; do
    if [ -f "$file" ]; then
        FILENAME=$(basename "$file")
        #ARTIFACT_ID=$(echo "$FILENAME" | sed -E 's/\.jar$//; s/[0-9-]+//g; s/\.{2,}/./g; s/\.$//')
        #VERSION=$(echo "$FILENAME" | sed -E 's/[^0-9]*([0-9][0-9.]*[0-9])[^0-9]*\.jar/\1/')
        #ARTIFACT_ID=$(echo "$FILENAME" | sed -E 's/-[0-9][0-9.]*\.jar//')
        #VERSION=$(echo "$FILENAME" | sed -E 's/[^0-9]*([0-9][0-9.]*[0-9])[^0-9]*\.jar/\1/')

        # Generate POM file
        POM_FILE="${FILES_DIR}/${ARTIFACT_ID}-${VERSION}.pom"
        cat <<EOF > $POM_FILE
<?xml version="1.0" encoding="UTF-8"?>
<project xmlns="http://maven.apache.org/POM/4.0.0" 
         xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
         xsi:schemaLocation="http://maven.apache.org/POM/4.0.0 http://maven.apache.org/maven-v4_0_0.xsd">
    <modelVersion>4.0.0</modelVersion>
    <groupId>$GROUP_ID</groupId>
    <artifactId>$ARTIFACT_ID</artifactId>
    <version>$VERSION</version>
</project>
EOF

        # Upload JAR
        echo "Uploading $FILENAME to GitHub Package Maven registry..."
        curl -v -X PUT \
            -u "$USERNAME:$TOKEN" \
            -H "Content-Type: application/octet-stream" \
            --data-binary "@$file" \
            "https://maven.pkg.github.com/$REPO_OWNER/$REPO_NAME/$GROUP_ID/$ARTIFACT_ID/$VERSION/$FILENAME?publish=1"

        # Upload POM
        echo "Uploading ${ARTIFACT_ID}-${VERSION}.pom to GitHub Package Maven registry..."
        curl -v -X PUT \
            -u "$USERNAME:$TOKEN" \
            -H "Content-Type: application/octet-stream" \
            --data-binary "@$POM_FILE" \
            "https://maven.pkg.github.com/$REPO_OWNER/$REPO_NAME/$GROUP_ID/$ARTIFACT_ID/$VERSION/${ARTIFACT_ID}-${VERSION}.pom?publish=1"

        echo "Upload process complete for $ARTIFACT_ID."
    fi
done
