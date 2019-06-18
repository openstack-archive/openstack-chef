Scripts
=======

# install.sh

[Chef Omnitruck installation script](https://docs.chef.io/install_omnibus.html)
which is used directly by Zuul to install Chef for the
openstack-chef-integration job.

To update, do the following:
``` shell
$ wget https://omnitruck.chef.io/install.sh
```

# json_check.sh

Script used to check JSON syntax in data bags, roles and environment files used
in testing.

Usage (from root of the repository):
```shell
$ ./scripts/json_check.sh
```
