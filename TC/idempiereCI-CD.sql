* EXACT SCRIPT (NO CONFUSION VERSION)

# Step 1: detect changed plugins
CHANGED=$(git diff --name-only HEAD~1 | awk -F'/' '{print $1"/"$2}' | sort -u)

echo "Changed plugins: $CHANGED"

# Step 2: clean output folder
rm -rf output
mkdir output

# Step 3: build + collect jars
for plugin in $CHANGED; do
  echo "Building $plugin"

  mvn -pl $plugin -am clean package

  echo "Copying jar of $plugin"

  find $plugin/target -name "*.jar" ! -name "*sources.jar" -exec cp {} output/ \;

  #cp $plugin/target/*.jar output/
done

BUILD_ID=$(date +%s)

echo "Uploading to S3..."

aws s3 cp output/ s3://your-bucket/plugins/$BUILD_ID/ --recursive

echo "BUILD_ID=$BUILD_ID" > build.env


* DEPLOY SCRIPT (UPDATED – CORRECT WAY)

#!/bin/bash

PLUGIN_DIR="/opt/idempiere-server/plugins"
S3_PATH="s3://your-bucket/plugins/$1/"

echo "Stopping iDempiere..."
sudo systemctl stop idempiere

echo "Downloading updated plugins..."

FILES=$(aws s3 ls $S3_PATH | awk '{print $4}')

for file in $FILES; do
    echo "Updating $file"
    rm -f $PLUGIN_DIR/$file
    aws s3 cp $S3_PATH$file $PLUGIN_DIR/
done

echo "Starting iDempiere..."
sudo systemctl start idempiere

echo "Deployment complete"

* SSM COMMAND (FINAL)

aws ssm send-command \
  --instance-ids "i-xxx" \
  --document-name "AWS-RunShellScript" \
  --parameters "commands=[
    'bash /home/ubuntu/deploy_plugins.sh $BUILD_ID'
  ]"

