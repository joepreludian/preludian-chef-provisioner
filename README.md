# Preludian CHEF Provisioner
A simple way to trigger a chef build on a instance through a ssh connection.
The only two params needed for the command, initially, is the IP of the instance and the password.

**BEWARE**: you will need to pass the root password.

## Expected scenario
The main idea of this tool is to converge an instance and setup your environment; you should create a recipe to override the root password.

## How to use it
The command is pretty simple.

    $ provisioner.sh <fqdn> <root password>;

The `bundle.tar.gz` must be present;

## About bundle.tar.gz
This bundle file was conceived in order to get a simple and viable cookbook for being provisioned on the target instance.
This file should contain the following structure:

```
  * cookbooks/
  * node.json
  * provision_chef.sh
```

### How to create a bundle.tar.gz file?
The strategy to create this bundle file is the following;

1. On your chef cookbook, create a cookbook package using the following command:
    $ berks package;
2. Create a folder and unpack the cookbooks-_timestamp_.tar.gz;
3. Inside that folder, create a file `node.json` and put the basic chef node json on it;
4. Create a file, with write perms, called `provision_chef.sh` and create a simple bash script that does the following:
  * Downloads the chef-client installer;
  * runs the chef-client on a solo mode, passing the node.json file.

## What to do next?
This command is pretty simple. The idea is to enhance the interface, creating the bundle.tar.gz and letting this tool install the chef client and triggering the chef-client, as described on the steps above. Also we need to create more checks and create a more stable command.
