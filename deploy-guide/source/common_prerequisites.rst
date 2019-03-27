Prerequisites
-------------

Before you install and configure the OpenStack Chef service,
you must create a database, service credentials, and API endpoints.

#. To create the database, complete these steps:

   * Use the database access client to connect to the database
     server as the ``root`` user:

     .. code-block:: console

        $ mysql -u root -p

   * Create the ``OpenStackChef`` database:

     .. code-block:: none

        CREATE DATABASE OpenStackChef;

   * Grant proper access to the ``OpenStackChef`` database:

     .. code-block:: none

        GRANT ALL PRIVILEGES ON OpenStackChef.* TO 'OpenStackChef'@'localhost' \
          IDENTIFIED BY 'OPENSTACKCHEF_DBPASS';
        GRANT ALL PRIVILEGES ON OpenStackChef.* TO 'OpenStackChef'@'%' \
          IDENTIFIED BY 'OPENSTACKCHEF_DBPASS';

     Replace ``OPENSTACKCHEF_DBPASS`` with a suitable password.

   * Exit the database access client.

     .. code-block:: none

        exit;

#. Source the ``admin`` credentials to gain access to
   admin-only CLI commands:

   .. code-block:: console

      $ . admin-openrc

#. To create the service credentials, complete these steps:

   * Create the ``OpenStackChef`` user:

     .. code-block:: console

        $ openstack user create --domain default --password-prompt OpenStackChef

   * Add the ``admin`` role to the ``OpenStackChef`` user:

     .. code-block:: console

        $ openstack role add --project service --user OpenStackChef admin

   * Create the OpenStackChef service entities:

     .. code-block:: console

        $ openstack service create --name OpenStackChef --description "OpenStack Chef" openstack chef

#. Create the OpenStack Chef service API endpoints:

   .. code-block:: console

      $ openstack endpoint create --region RegionOne \
        openstack chef public http://controller:XXXX/vY/%\(tenant_id\)s
      $ openstack endpoint create --region RegionOne \
        openstack chef internal http://controller:XXXX/vY/%\(tenant_id\)s
      $ openstack endpoint create --region RegionOne \
        openstack chef admin http://controller:XXXX/vY/%\(tenant_id\)s
