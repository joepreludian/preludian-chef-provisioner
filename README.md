# Preludian CHEF Provisioner
A simple way to trigger a chef build on a instance through a ssh connection.
The only two params needed for the command, initially, is the IP of the instance and the password.

**REMARK**: you will need to pass the root password.

## Expected scenario
The main idea of this tool is to converge an instance and setup your environment; you should create a recipe to override the root password.

## How to use it
The command is pretty simple.

    $ ./provisioner.sh <fqdn> <root password>;

If will look for two files in order to keep going:

* cookbooks.tar.gz - This file is generated from your cookbook using the `berks package` command;
* node.json - A single node.json file, used by chef in order to bootstrap your instance. More information can be found at [](https://docs.chef.io/knife_node.html);

For more configurations, please look at the comand usage by simple triggering:

    $ ./provisioner.sh

## Contribute
Ideas, suggestions and etc, would be appreciated!

Thank you! I hope that this tool could be useful for your work. =)
