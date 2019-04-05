2. Edit the ``/etc/OpenStackChef/OpenStackChef.conf`` file and complete the following
   actions:

   * In the ``[database]`` section, configure database access:

     .. code-block:: ini

        [database]
        ...
        connection = mysql+pymysql://OpenStackChef:OPENSTACKCHEF_DBPASS@controller/OpenStackChef
