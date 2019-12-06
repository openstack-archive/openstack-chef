Scripts
=======

install.sh
==========

`Chef Omnitruck installation script`_ which is used directly by Zuul to
install Chef for the openstack-chef-integration job.

.. _Chef Omnitruck installation script: https://docs.chef.io/install_omnibus.html

To update, do the following:

.. code-block:: console

  $ wget https://omnitruck.chef.io/install.sh

json_check.sh
=============

Script used to check JSON syntax in data bags, roles and environment
files used in testing.

Usage (from root of the repository):

.. code-block:: console

  $ ./scripts/json_check.sh
