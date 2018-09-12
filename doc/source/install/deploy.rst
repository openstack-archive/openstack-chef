.. _deploy:

===============================
Deploy Chef OpenStack cookbooks
===============================

Deploy Chef OpenStack cookbooks, using Chef, and test the setup using
Tempest.

* Software requirements:

  * Ubuntu 18.04 LTS or CentOS 7 fresh install
  * `git` installed
  * `chef-client` installed: https://docs.chef.io/#setup

* Hardware requirements:

  * At least 4GB of memory. 8GB or more is recommended.
  * At least 10GB of storage.

.. code-block:: bash

  $ git clone https://git.openstack.org/openstack/openstack-chef
  $ cd openstack-chef
  # mkdir -p /etc/chef && cp .chef/encrypted_data_bag_secret /etc/chef/openstack_data_bag_secret
  # chef-client -z -E allinone -r 'role[allinone]'
