=============
Cookbook List
=============

Each Chef OpenStack cookbook corresponds to an OpenStack component and has its
own git repository. The cookbooks produce a number of deliverables, in order to
achieve a clearly stated objective: deploy OpenStack.

OpenStack Cookbooks
===================

* `Bare Metal <https://opendev.org/cgit/openstack/cookbook-openstack-bare-metal/>`_ (*Ironic*)
* `Block Storage <https://opendev.org/cgit/openstack/cookbook-openstack-block-storage/>`_ (*Cinder*)
* `Compute <https://opendev.org/cgit/openstack/cookbook-openstack-compute/>`_ (*Nova*)
* `Dashboard <https://opendev.org/cgit/openstack/cookbook-openstack-dashboard/>`_ (*Horizon*)
* `DNS <https://opendev.org/cgit/openstack/cookbook-openstack-dns/>`_ (*Designate*)
* `Image <https://opendev.org/cgit/openstack/cookbook-openstack-image/>`_ (*Glance*)
* `Network <https://opendev.org/cgit/openstack/cookbook-openstack-network/>`_ (*Neutron*)
* `Orchestration <https://opendev.org/cgit/openstack/cookbook-openstack-orchestration/>`_ (*Heat*)
* `Telemetry <https://opendev.org/cgit/openstack/cookbook-openstack-telemetry/>`_ (*Ceilometer*/*Gnocchi*)

Operations Cookbooks
====================
* `Database <https://opendev.org/cgit/openstack/cookbook-openstack-ops-database/>`_ (*MariaDB*/*MySQL*)
* `Messaging <https://opendev.org/cgit/openstack/cookbook-openstack-ops-messaging/>`_ (*RabbitMQ*)

Supporting Repositories
=======================
* `Client <https://opendev.org/cgit/openstack/cookbook-openstackclient>`_ (LWRPs for using fog-openstack inside Chef recipes)
* `Integration Test <https://opendev.org/cgit/openstack/cookbook-openstack-integration-test/>`_ (Build cookbook to deploy and test using Tempest)

Unmaintained Cookbooks
==============================
* `Object Storage <https://opendev.org/cgit/openstack/cookbook-openstack-object-storage/>`_ (*Swift*)
* `Data Processing <https://opendev.org/cgit/openstack/cookbook-openstack-data-processing/>`_ (*Sahara*)
* `Application Catalog <https://opendev.org/cgit/openstack/cookbook-openstack-application-catalog/>`_ (*Murano*)
* `Database as a Service <https://opendev.org/cgit/openstack/cookbook-openstack-database/>`_ (*Trove*)
