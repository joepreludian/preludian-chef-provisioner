#!/bin/bash

VERSION='0.2.0';

echo -e "Preludian SSH Provisioner [${VERSION}]";

function credentials_create {
  TEMP_CREDENTIALS_FILE=$(mktemp);
  
  echo "echo \"${PASSWD}\"" > $TEMP_CREDENTIALS_FILE;
  chmod +x $TEMP_CREDENTIALS_FILE;
  
  export SSH_ASKPASS=$TEMP_CREDENTIALS_FILE;
}

function credentials_delete {
  rm $TEMP_CREDENTIALS_FILE;
  unset SSH_ASKPASS;
  echo "Temp file deleted.";
}

function display_help {
  echo -e "  How to use it?\n    $0 <address_of_your_machine> <root_password_of_your_instance>\n";
  echo -e "  Advanced usage:\n    you can also set some environment variables like:\n";
  echo -e "      CHEF_CLIENT_VERSION=\"${CHEF_CLIENT_VERSION}\" - more information about omnibus: https://docs.chef.io/install_omnibus.html\n      COOKBOOKS_FILENAME=\"${COOKBOOKS_FILENAME}\"\n      NODEJSON_FILENAME=\"${NODEJSON_FILENAME}\"";
  echo;
  exit 1;
}

function run_ssh {  # usage run_ssh <command>;
  setsid ssh -oStrictHostKeyChecking=no root@${ADDRESS} '$1';

  if [ $? -ne 0 ]; then echo "Command Failed."; credentials_delete; exit 1; fi
}

function run_scp {  # usage run_scp <from> <to>;
  setsid scp -oStrictHostKeyChecking=no $1 root@${ADDRESS}:$2;

  if [ $? -ne 0 ]; then echo "Command Failed."; credentials_delete; exit 1; fi
}

# Optional params that it would be passed as environment variables;
if [ -z "$CHEF_CLIENT_VERSION" ]; then CHEF_CLIENT_VERSION='15.2.20'; fi
if [ -z "$COOKBOOKS_FILENAME" ]; then COOKBOOKS_FILENAME='cookbooks.tar.gz'; fi
if [ -z "$NODEJSON_FILENAME" ]; then NODEJSON_FILENAME='node.json'; fi

# Mandatory params
ADDRESS=$1; if [ -z "$ADDRESS" ]; then display_help; fi
PASSWD=$2; if [ -z "$PASSWD" ]; then display_help; fi

# Checking for missing files
echo "Verifying needed files..."
if [ -f "${COOKBOOKS_FILENAME}" ]; then echo "${COOKBOOKS_FILENAME} exists."; else echo "${COOKBOOKS_FILENAME} not found. Please provide this file and then run this tool again"; exit 1; fi
if [ -f "${NODEJSON_FILENAME}" ]; then echo "${NODEJSON_FILENAME} exists."; else echo "${NODEJSON_FILENAME} not found. Please provide this file and then run this tool again"; exit 1; fi
echo "Files verified. Proceeding to instance setup through SSH";
exit 1;

# Script begin
echo "Installing Chef OMNIBUS on target...";
run_ssh "curl -L https://omnitruck.chef.io/install.sh | sudo bash -s -- -v ${CHEF_CLIENT_VERSION}";

echo "Preparing /chef folder on instance...";
run_ssh 'rm -Rf /chef/ || true && mkdir /chef/';

echo "Sending the cookbooks package to /chef...";
run_scp $COOKBOOKS_FILENAME '/chef/';
run_scp $NODEJSON_FILENAME '/chef/';

echo "Deploying project...";
run_ssh "cd /chef/ && tar zxvf ${COOKBOOKS_FILENAME} && chef-client --chef-license accept-silent -z -j ${NODEJSON_FILENAME}";

echo "Done!";
