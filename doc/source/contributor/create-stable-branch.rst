Steps to create a stable release branch
=======================================

Awesome! We've decided as a group to create the next stable branch. Here
are some steps to remind you on how to do it.

#. Go to `each repo`_ as a core member and create the branch with the
   SHA you want, usually you will just branch from master.::

     git checkout master
     git pull
     git checkout -b stable/<release>
     git push gerrit stable/<release>

#. Changes for each cookbook and repo, create a bug to tie all the
   following branch work together

   a. Update ``.gitreview`` to include ``defaultbranch=stable/<release>``

   b. Update ``Berksfile`` to reference ``branch: 'stable/<release>'`` for each branched cookbook

   c. See https://review.opendev.org/729795 for an example

#. Create a review with the above and put it up against the ``stable/<release>`` branch.

#. Get it merged in and you should be good

.. _each repo: https://governance.openstack.org/tc/reference/projects/openstack-chef.html

If you think doing this manually for all the cookbooks is a lot of work,
these commands might help you automating it (please CHECK the git diff
before you actually push something):

#. First pull all the cookbooks into one folder and then try to run
   these commands one by one from the root folder (they are
   intentionally separated, since they will create some changes that you
   do not want to push).

   .. code-block:: bash

     for i in -bare-metal -block-storage client -common -compute \
       -dashboard -dns -identity -image -integration-test -network \
       -ops-database -ops-messaging -orchestration -telemetry ; do
       git clone https://opendev.org/openstack/cookbook-openstack${i}
     done

#. Check your ``sed`` version and make sure you have at least version
   4.2.1 (if you are on OS X you have to install ``gnu-sed`` via
   Homebrew since the one installed does work in mysterious ways).

   .. code-block:: bash

     export RELEASE=train
     for i in $(ls | grep cookbook) ; do
       cd $i
       git checkout -b stable/${RELEASE}
       sed -i "/opendev/a\ \ branch: 'stable\/${RELEASE}'" Berksfile
       sed -i 's/opendev.*$/&,/' Berksfile
       echo "defaultbranch=stable/${RELEASE}" >> .gitreview
       cd ..
     done

     # The next one is important, since there are changes that are wrong
     # and should be corrected manually (like adding the branch:
     # stable/train for a non-openstack cookbook)
     for i in $(ls | grep cookbook) ; do cd $i; git diff; cd .. ; done | less

     # After you checked all your changes, you can go ahead, commit it and
     # push it up for review.
     for i in $(ls | grep cookbook) ; do
       cd $i
       git review -s
       git commit -am "stable/${RELEASE} release patch"
       git review
       cd ..
     done

Steps for a new master branch
-----------------------------

.. note::

  These steps are also useful when making global changes that are
  dependent on each other.

Now we have a new master, need to get it in sync with matching base
OpenStack release.

#. Possible infra changes for changes to the gates we want for this
   release.

#. Decide on new levels of tools (Chef Workstation, Cookstyle, upstream
   cookbooks), we have always be trying to move forward with these.

#. Changes for each cookbook and repo:

   a. Update metadata with new major version level

   c. Run ``cookstyle -a`` to fix any style issues. Run Cookstyle again
      and fix any issues that couldn't be fixed automatically.

   d. Update code with refs to old OpenStack release, i.e. "ocata" ->
      "pike"  (Common release and yum attributes, ...).

   e. Update all code looking for deprecation's that can now be removed.

   f. Update any package dependencies that have changed for each
      component.

   g. Update all spec test platforms to targeted levels we want for this
      release.

It will likely be necessary to disable integration jobs from being
voting on the ``openstack-chef`` repo in order to allow to merge all
these changes. If you do so, make sure that you have one patch at the
end which depends on all others, this one should be passing all
integration jobs again before you merge anything. See this `topic`_ as
an example.

.. _topic: https://review.opendev.org/#/q/topic:train-updates+(status:open+OR+status:merged)

You will want to do this in the following order and add ``Depends-On:``
to each review to it's dependencies. Everything should depend on the
openstack-chef repo since that's where all of the tests reside and will
need to be updated. To simplify, you can chain dependencies based on
their ``metadata.rb`` dependencies. See below on specifics:

#. openstack-chef Repo
#. Common (depends on openstack-chef)
#. Client (depends on openstack-chef and Common)
#. Ops-Messaging (depends on openstack-chef)
#. Ops-Database (depends on openstack-chef)
#. Identity (depends on Client, Ops-Messaging and Ops-Database)
#. Image (depends on Identity)
#. Block-Storage (depends on Image)
#. Network (depends on Identity)
#. Compute (depends on Image and Network)
#. Dns (depends on Network)
#. Orchestration (depends on Identity)
#. Telemetry (depends on Identity)
#. Dashboard (depends on Identity)
#. Integration-Test (depends on Image and Dns)
