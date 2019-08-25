#!/bin/bash

VERSION="0.1.0";

echo "Preludian SSH Provisioner - ${VERSION}";

function delete_tempfile {
  rm $TEMP_CREDENTIALS_FILE;
  echo "Temp file deleted.";
}

TEMP_CREDENTIALS_FILE=$(mktemp);
ADDRESS=$1;
PASSWD=$2;

echo "ADDRESS: ${ADDRESS}; PASSWD: ${PASSWD}";

echo "echo \"${PASSWD}\"" > $TEMP_CREDENTIALS_FILE;
chmod +x $TEMP_CREDENTIALS_FILE;
export SSH_ASKPASS=$TEMP_CREDENTIALS_FILE;

echo "Preparing /chef folder on node...";
setsid ssh -oStrictHostKeyChecking=no root@${ADDRESS} 'df -h && free -mh';

if [ $? -ne 0 ]; then echo "Command Failed."; delete_tempfile; exit 1; fi

setsid ssh -oStrictHostKeyChecking=no root@${ADDRESS} 'rm -Rf /chef/ || true && mkdir /chef/';

echo "Sending the bundle package...";
setsid scp -oStrictHostKeyChecking=no bundle.tar.gz root@${ADDRESS}:/chef/;

echo "Deploying project...";
setsid ssh -oStrictHostKeyChecking=no root@${ADDRESS} 'cd /chef/ && tar zxvf bundle.tar.gz && ./provision_chef.sh';

if [ $? -eq 0 ]
then
  echo "SSH Command has been executed sucessfully.";
  delete_tempfile;
  exit 0;
else
  echo "The command exited without success. Please look at the logs.";
  delete_tempfile;
  exit 1;
fi

