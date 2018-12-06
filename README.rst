
=====
Usage
=====

Salt is a new approach to infrastructure management. Easy enough to get
running in minutes, scalable enough to manage tens of thousands of servers,
and fast enough to communicate with them in seconds.

Salt delivers a dynamic communication bus for infrastructures that can be used
for orchestration, remote execution, configuration management and much more.

Sample Metadata
===============

Salt Master
-----------

Salt master with base formulas and pillar metadata back end:

.. literalinclude:: tests/pillar/master_single_pillar.sls
   :language: yaml

Salt master with reclass ENC metadata back end:

.. literalinclude:: tests/pillar/master_single_reclass.sls
   :language: yaml

Salt master with Architect ENC metadata back end:

.. code-block:: yaml

    salt:
      master:
        enabled: true
        pillar:
          engine: architect
          project: project-name
          host: architect-api
          port: 8181
          username: salt
          password: password

Salt master with multiple ``ext_pillars``:

.. code-block:: yaml

    salt:
      master:
        enabled: true
        pillar:
          engine: salt
          source:
            engine: local
        ext_pillars:
          1:
            module: cmd_json
            params: '"echo {\"arg\": \"val\"}"'
          2:
            module: cmd_yaml
            params: /usr/local/bin/get_yml.sh

Salt master with API:

.. literalinclude:: tests/pillar/master_api.sls
   :language: yaml

Salt master with defined user ACLs:

.. literalinclude:: tests/pillar/master_acl.sls
   :language: yaml

Salt master with preset minions:

.. code-block:: yaml

    salt:
      master:
        enabled: true
        minions:
        - name: 'node1.system.location.domain.com'

Salt master with pip based installation (optional):

.. code-block:: yaml

    salt:
      master:
        enabled: true
        ...
        source:
          engine: pip
          version: 2016.3.0rc2

Install formula through system package management:

.. code-block:: yaml

    salt:
      master:
        enabled: true
        ...
        environment:
          prd:
            keystone:
              source: pkg
              name: salt-formula-keystone
            nova:
              source: pkg
              name: salt-formula-keystone
              version: 0.1+0~20160818133412.24~1.gbp6e1ebb
            postresql:
              source: pkg
              name: salt-formula-postgresql
              version: purged

Formula keystone is installed latest version and the formulas
without version are installed in one call to aptpkg module.
If the version attribute is present sls iterates over formulas
and take action to install specific version or remove it.
The version attribute may have these values
``[latest|purged|removed|<VERSION>]``.

Clone master branch of keystone formula as local feature branch:

.. code-block:: yaml

    salt:
      master:
        enabled: true
        ...
        environment:
          dev:
            formula:
              keystone:
                source: git
                address: git@github.com:openstack/salt-formula-keystone.git
                revision: master
                branch: feature

Salt master with specified formula refs (for example, for Gerrit
review):

.. code-block:: yaml

    salt:
      master:
        enabled: true
        ...
        environment:
          dev:
            formula:
              keystone:
                source: git
                address: https://git.openstack.org/openstack/salt-formula-keystone
                revision: refs/changes/56/123456/1

Salt master logging configuration:

.. code-block:: yaml

    salt:
      master:
        enabled: true
        log:
          level: warning
          file: '/var/log/salt/master'
          level_logfile: warning

Salt minion logging configuration:

.. code-block:: yaml

    salt:
      minion:
        enabled: true
        log:
          level: info
          file: '/var/log/salt/minion'
          level_logfile: warning

Salt master with logging handlers:

.. code-block:: yaml

    salt:
      master:
        enabled: true
        handler:
          handler01:
            engine: udp
            bind:
              host: 127.0.0.1
              port: 9999
      minion:
        handler:
          handler01:
            engine: udp
            bind:
              host: 127.0.0.1
              port: 9999
          handler02:
            engine: zmq
            bind:
              host: 127.0.0.1
              port: 9999

Salt engine definition for saltgraph metadata collector:

.. code-block:: yaml

    salt:
      master:
        engine:
          graph_metadata:
            engine: saltgraph
            host: 127.0.0.1
            port: 5432
            user: salt
            password: salt
            database: salt

Salt engine definition for Architect service:

.. code-block:: yaml

    salt:
      master:
        engine:
          architect:
            engine: architect
            project: project-name
            host: architect-api
            port: 8181
            username: salt
            password: password

Salt engine definition for sending events from docker events:

.. code-block:: yaml

    salt:
      master:
        engine:
          docker_events:
            docker_url: unix://var/run/docker.sock

Salt master peer setup for remote certificate signing:

.. code-block:: yaml

    salt:
      master:
        peer:
          ".*":
          - x509.sign_remote_certificate

Salt master backup configuration:

.. code-block:: yaml

    salt:
      master:
        backup: true
        initial_data:
          engine: backupninja
          home_dir: remote-backup-home-dir
          source: backup-node-host
          host: original-salt-master-id

Configure verbosity of state output (used for :command:`salt`
command):

.. code-block:: yaml

    salt:
      master:
        state_output: changes

Pass pillar render error to minion log:

.. note:: When set to `False` this option is great for debuging.
   However it is not recomended for any production environment as it may contain
   templating data as passwords, and so on, that minion should not expose.

.. code-block:: yaml

    salt:
      master:
        pillar_safe_render_error: False

Enable Windows repository support:

.. code-block:: yaml

    salt:
      master:
        win_repo:
          source: git
          address: https://github.com/saltstack/salt-winrepo-ng
          revision: master

Configure a gitfs_remotes resource:

.. code-block:: yaml

    salt:
      master:
        gitfs_remotes:
          salt_formula:
            url: https://github.com/salt-formulas/salt-formula-salt.git
            enabled: true
            params:
              base: master

Read more about gitfs resource options in the official Salt documentation.


Event/Reactor systems
~~~~~~~~~~~~~~~~~~~~~

Salt to synchronize node pillar and modules after start:

.. code-block:: yaml

    salt:
      master:
        reactor:
          salt/minion/*/start:
          - salt://salt/reactor/node_start.sls

Trigger basic node install:

.. code-block:: yaml

    salt:
      master:
        reactor:
          salt/minion/install:
          - salt://salt/reactor/node_install.sls

Sample event to trigger the node installation:

.. code-block:: bash

    salt-call event.send 'salt/minion/install'

Run any defined orchestration pipeline:

.. code-block:: yaml

    salt:
      master:
        reactor:
          salt/orchestrate/start:
          - salt://salt/reactor/orchestrate_start.sls

Event to trigger the orchestration pipeline:

.. code-block:: bash

    salt-call event.send 'salt/orchestrate/start' "{'orchestrate': 'salt/orchestrate/infra_install.sls'}"

Synchronise modules and pillars on minion start:

.. code-block:: yaml

    salt:
      master:
        reactor:
          'salt/minion/*/start':
          - salt://salt/reactor/minion_start.sls

Add and/or remove the minion key:

.. code-block:: yaml

    salt:
      master:
        reactor:
          salt/key/create:
          - salt://salt/reactor/key_create.sls
          salt/key/remove:
          - salt://salt/reactor/key_remove.sls

Event to trigger the key creation:

.. code-block:: bash

    salt-call event.send 'salt/key/create' \
    > "{'node_id': 'id-of-minion', 'node_host': '172.16.10.100', 'orch_post_create': 'kubernetes.orchestrate.compute_install', 'post_create_pillar': {'node_name': 'id-of-minion'}}"

.. note::

    You can add pass additional ``orch_pre_create``, ``orch_post_create``,
    ``orch_pre_remove`` or ``orch_post_remove`` parameters to the event
    to call extra orchestrate files. This can be useful for example for
    registering/unregistering nodes from the monitoring alarms or dashboards.

    The key creation event needs to be run from other machine than the one
    being registered.

Event to trigger the key removal:

.. code-block:: bash

    salt-call event.send 'salt/key/remove'

Control VM provisioning:

.. code-block:: yaml

    _param:
      private-ipv4: &private-ipv4
      - id: private-ipv4
        type: ipv4
        link: ens2
        netmask: 255.255.255.0
        routes:
        - gateway: 192.168.0.1
          netmask: 0.0.0.0
          network: 0.0.0.0
    virt:
      disk:
        three_disks:
          - system:
              size: 4096
              image: ubuntu.qcow
          - repository_snapshot:
              size: 8192
              image: snapshot.qcow
          - cinder-volume:
              size: 2048
      nic:
        control:
        - name: nic01
          bridge: br-pxe
          model: virtio
        - name: nic02
          bridge: br-cp
          model: virtio
        - name: nic03
          bridge: br-store-front
          model: virtio
        - name: nic04
          bridge: br-public
          model: virtio
        - name: nic05
          bridge: br-prv
          model: virtio
          virtualport:
            type: openvswitch

    salt:
      control:
        enabled: true
        virt_enabled: true
        size:
          medium_three_disks:
            cpu: 2
            ram: 4
            disk_profile: three_disks
        cluster:
          mycluster:
            domain: neco.virt.domain.com
            engine: virt
            # Cluster global settings
            rng: false
            enable_vnc: True
            seed: cloud-init
            cloud_init:
              user_data:
                disable_ec2_metadata: true
                resize_rootfs: True
                timezone: UTC
                ssh_deletekeys: True
                ssh_genkeytypes: ['rsa', 'dsa', 'ecdsa']
                ssh_svcname: ssh
                locale: en_US.UTF-8
                disable_root: true
                apt_preserve_sources_list: false
                apt:
                  sources_list: ""
                  sources:
                    ubuntu.list:
                      source: ${linux:system:repo:ubuntu:source}
                    mcp_saltstack.list:
                      source: ${linux:system:repo:mcp_saltstack:source}
            node:
              ubuntu1:
                provider: node01.domain.com
                image: ubuntu.qcow
                size: medium
                img_dest: /var/lib/libvirt/ssdimages
                # Node settings override cluster global ones
                enable_vnc: False
                rng:
                  backend: /dev/urandom
                  model: random
                  rate:
                    period: '1800'
                    bytes: '1500'
                # Custom per-node loader definition (e.g. for AArch64 UEFI)
                loader:
                  readonly: yes
                  type: pflash
                  path: /usr/share/AAVMF/AAVMF_CODE.fd
                machine: virt-2.11  # Custom per-node virt machine type
                cpu_mode: host-passthrough
                cpuset: '1-4'
                mac:
                  nic01: AC:DE:48:AA:AA:AA
                  nic02: AC:DE:48:AA:AA:BB
                # netconfig affects: hostname during boot
                # manual interfaces configuration
                cloud_init:
                  network_data:
                    networks:
                    - <<: *private-ipv4
                      ip_address: 192.168.0.161
                  user_data:
                    salt_minion:
                      conf:
                        master: 10.1.1.1
              ubuntu2:
                seed: qemu-nbd
                cloud_init:
                  enabled: false

There are two methods to seed an initial Salt minion configuration to
Libvirt VMs: mount a disk and update a filesystem or create a ConfigDrive with
a Cloud-init config. This is controlled by the "seed" parameter on cluster and
node levels. When set to _True_ or "qemu-nbd", the old method of mounting a disk
will be used. When set to "cloud-init", the new method will be used. When set
to _False_, no seeding will happen. The default value is _True_, meaning
the "qemu-nbd" method will be used. This is done for backward compatibility
and may be changed in future.

The recommended method is to use Cloud-init.
It's controlled by the "cloud_init" dictionary on cluster and node levels.
Node level parameters are merged on top of cluster level parameters.
The Salt Minion config is populated automatically based on a VM name and config
settings of the minion who is actually executing a state. To override them,
add the "salt_minion" section into the "user_data" section as shown above.
It is possible to disable Cloud-init by setting "cloud_init.enabled" to _False_.

To enable Redis plugin for the Salt caching subsystem, use the
below pillar structure:

.. code-block:: yaml

  salt:
    master:
      cache:
        plugin: redis
        host: localhost
        port: 6379
        db: '0'
        password: pass_word
        bank_prefix: 'MCP'
        bank_keys_prefix: 'MCPKEY'
        key_prefix: 'KEY'
        separator: '@'

Jinja options
-------------

Use the following options to update default Jinja renderer options.
Salt recognize Jinja options for templates and for the ``sls`` files.

For full list of options, see Jinja documentation:
http://jinja.pocoo.org/docs/api/#high-level-api

.. code-block:: yaml

  salt:
    renderer:
      # for templates
      jinja: &jina_env
        # Default Jinja environment options
        block_start_string: '{%'
        block_end_string: '%}'
        variable_start_string: '{{'
        variable_end_string: '}}'
        comment_start_string: '{#'
        comment_end_string: '#}'
        keep_trailing_newline: False
        newline_sequence: '\n'

        # Next two are enabled by default in Salt
        trim_blocks: True
        lstrip_blocks: True

        # Next two are not enabled by default in Salt
        # but worth to consider to enable in future for salt-formulas
        line_statement_prefix: '%'
        line_comment_prefix: '##'

      # for .sls state files
      jinja_sls: *jinja_env

With the ``line_statement/comment* _prefix`` options enabled following
code statements are valid:

.. code-block:: yaml

   %- set myvar = 'one'

   ## You can mix even with '{%'
   {%- set myvar = 'two' %} ## comment
   %- set mylist = ['one', 'two', 'three'] ## comment

   ## comment
   %- for item in mylist:  ## comment
   {{- item }}
   %- endfor

Encrypted pillars
~~~~~~~~~~~~~~~~~

.. note:: NACL and the below configuration will be available in Salt > 2017.7.

External resources:

- Tutorial to configure the Salt and Reclass ``ext_pillar`` and NACL:
  http://apealive.net/post/2017-09-salt-nacl-ext-pillar/
- SaltStack documentation:
  https://docs.saltstack.com/en/latest/ref/modules/all/salt.modules.nacl.html

Configure salt NACL module:

.. code-block:: bash

  pip install --upgrade libnacl===1.5.2
  salt-call --local nacl.keygen /etc/salt/pki/master/nacl

    local:
        saved sk_file:/etc/salt/pki/master/nacl  pk_file: /etc/salt/pki/master/nacl.pub

.. code-block:: yaml

    salt:
      master:
        pillar:
          reclass: *reclass
          nacl:
            index: 99
        nacl:
          box_type: sealedbox
          sk_file: /etc/salt/pki/master/nacl
          pk_file: /etc/salt/pki/master/nacl.pub
          #sk: None
          #pk: None

NACL encrypt secrets:

.. code-block:: bash

  salt-call --local nacl.enc 'my_secret_value' pk_file=/etc/salt/pki/master/nacl.pub
    hXTkJpC1hcKMS7yZVGESutWrkvzusXfETXkacSklIxYjfWDlMJmR37MlmthdIgjXpg4f2AlBKb8tc9Woma7q
  # or
  salt-run nacl.enc 'myotherpass'
    ADDFD0Rav6p6+63sojl7Htfrncp5rrDVyeE4BSPO7ipq8fZuLDIVAzQLf4PCbDqi+Fau5KD3/J/E+Pw=

NACL encrypted values on pillar:

Use Boxed syntax `NACL[CryptedValue=]` to encode value on pillar:

.. code-block:: yaml

  my_pillar:
    my_nacl:
        key0: unencrypted_value
        key1: NACL[hXTkJpC1hcKMS7yZVGESutWrkvzusXfETXkacSklIxYjfWDlMJmR37MlmthdIgjXpg4f2AlBKb8tc9Woma7q]

NACL large files:

.. code-block:: bash

  salt-call nacl.enc_file /tmp/cert.crt out=/srv/salt/env/dev/cert.nacl
  # or more advanced
  cert=$(cat /tmp/cert.crt)
  salt-call --out=newline_values_only nacl.enc_pub data="$cert" > /srv/salt/env/dev/cert.nacl

NACL within template/native pillars:

.. code-block:: yaml

  pillarexample:
      user: root
      password1: {{salt.nacl.dec('DRB7Q6/X5gGSRCTpZyxS6hlbWj0llUA+uaVyvou3vJ4=')|json}}
      cert_key: {{salt.nacl.dec_file('/srv/salt/env/dev/certs/example.com/cert.nacl')|json}}
      cert_key2: {{salt.nacl.dec_file('salt:///certs/example.com/cert2.nacl')|json}}

Salt Syndic
-----------

The master of masters:

.. code-block:: yaml

    salt:
      master:
        enabled: true
        order_masters: True

Lower syndicated master:

.. code-block:: yaml

    salt:
      syndic:
        enabled: true
        master:
          host: master-of-master-host
        timeout: 5

Syndicated master with multiple master of masters:

.. code-block:: yaml

    salt:
      syndic:
        enabled: true
        masters:
        - host: master-of-master-host1
        - host: master-of-master-host2
        timeout: 5

Dynamic DNS configuration
-------------------------

Salt master can register minions in DNS server using DDNS (dynamic DNS)
update mechanism via salt.runners.ddns module. DNS server with dynamic
updates allowed is required. Authorization via {tsig-key} is available.
Recommended is DNS server configured via salt-formula-bind.
Mechanism uses event-reactor system.

Master pillar:

.. code-block:: yaml

    salt:
      master:
        ddns:
          enabled: True
          keys:
            key: <tsig-key>
            name: <tsig-key-name>
        reactor:
          dns/node/register:
          - salt://salt/reactor/ddns_node_register.sls
          dns/static/records:
          - salt://salt/reactor/ddns_static_records.sls

Minion pillar:

.. code-block:: yaml

    salt:
      minion:
        ddns:
          server: <dns-server-ip>
          keyname: <tsig-key-name>
          ttl: 300
        dns_static:
          zone.example.com:
          - name: appname
            type: CNAME
            value: appserver01


Manual calling:

.. code-block:: bash
    # Minion register
    salt '*' state.apply salt.minion.dns_register
    #
    # Static DNS records
    salt '*' state.apply salt.minion.dns_static


Salt Minion
-----------

Minion ID by default triggers dependency on Linux formula, as it uses fqdn
configured from `linux.system.name` and `linux.system.domain` pillar.
To override, provide exact minion ID you require. The same can be set for
master ID rendered at ``master.conf``.

 .. code-block:: yaml

    salt:
      minion:
        id: minion1.production
      master:
        id: master.production

Simplest Salt minion setup with central configuration node:

.. literalinclude:: tests/pillar/minion_master.sls
   :language: yaml

Multi-master Salt minion setup:

.. literalinclude:: tests/pillar/minion_multi_master.sls
   :language: yaml

Salt minion with salt mine options:

.. literalinclude:: tests/pillar/minion_mine.sls
   :language: yaml

Salt minion with graphing dependencies:

.. literalinclude:: tests/pillar/minion_graph.sls
   :language: yaml

Salt minion behind HTTP proxy:

.. code-block:: yaml

    salt:
      minion:
        proxy:
          host: 127.0.0.1
          port: 3128

Salt minion to specify non-default HTTP backend. The default
tornado backend does not respect HTTP proxy settings set as
environment variables. This is useful for cases where you need
to set no_proxy lists.

.. code-block:: yaml

    salt:
      minion:
        backend: urllib2

Salt minion with PKI certificate authority (CA):

.. literalinclude:: tests/pillar/minion_pki_ca.sls
   :language: yaml

Salt minion using PKI certificate

.. literalinclude:: tests/pillar/minion_pki_cert.sls
   :language: yaml

Salt minion trust CA certificates issued by salt CA on a
specific host (ie: salt-master node):

.. code-block:: yaml

  salt:
    minion:
      trusted_ca_minions:
        - cfg01

Salt Minion Proxy
~~~~~~~~~~~~~~~~~

Salt proxy pillar:

.. code-block:: yaml

    salt:
      minion:
        proxy_minion:
          master: localhost
          device:
            vsrx01.mydomain.local:
              enabled: true
              engine: napalm
            csr1000v.mydomain.local:
              enabled: true
              engine: napalm

.. note:: This is pillar of the the real salt-minion

Proxy pillar for IOS device:

.. code-block:: yaml

    proxy:
      proxytype: napalm
      driver: ios
      host: csr1000v.mydomain.local
      username: root
      passwd: r00tme

.. note:: This is pillar of the node thats not able to run
   salt-minion itself.

Proxy pillar for JunOS device:

.. code-block:: yaml

    proxy:
      proxytype: napalm
      driver: junos
      host: vsrx01.mydomain.local
      username: root
      passwd: r00tme
      optional_args:
        config_format: set

.. note:: This pillar applies to the node that can not run
   salt-minion itself.

Salt SSH
~~~~~~~~

Salt SSH with sudoer using key:

.. literalinclude:: tests/pillar/master_ssh_minion_key.sls
   :language: yaml

Salt SSH with sudoer using password:

.. literalinclude:: tests/pillar/master_ssh_minion_password.sls
   :language: yaml

Salt SSH with root using password:

.. literalinclude:: tests/pillar/master_ssh_minion_root.sls
   :language: yaml

Salt control (cloud/kvm/docker)
-------------------------------

Salt cloud with local OpenStack provider:

.. literalinclude:: tests/pillar/control_cloud_openstack.sls
   :language: yaml

Salt cloud with Digital Ocean provider:

.. literalinclude:: tests/pillar/control_cloud_digitalocean.sls
   :language: yaml

Salt virt with KVM cluster:

.. literalinclude:: tests/pillar/control_virt.sls
   :language: yaml

Salt virt with custom destination for image file:

.. literalinclude:: tests/pillar/control_virt_custom.sls
   :language: yaml

Usage
=====

Working with salt-cloud:

.. code-block:: bash

    salt-cloud -m /path/to/map --assume-yes

Debug LIBCLOUD for salt-cloud connection:

.. code-block:: bash

    export LIBCLOUD_DEBUG=/dev/stderr; salt-cloud --list-sizes provider_name --log-level all

Read more
=========

* http://salt.readthedocs.org/en/latest/
* https://github.com/DanielBryan/salt-state-graph
* http://karlgrz.com/testing-salt-states-rapidly-with-docker/
* https://mywushublog.com/2013/03/configuration-management-with-salt-stack/
* http://russell.ballestrini.net/replace-the-nagios-scheduler-and-nrpe-with-salt-stack/
* https://github.com/saltstack-formulas/salt-formula
* http://docs.saltstack.com/en/latest/topics/tutorials/multimaster.html

salt-cloud
----------

* http://www.blog.sandro-mathys.ch/2013/07/setting-user-password-when-launching.html
* http://cloudinit.readthedocs.org/en/latest/topics/examples.html
* http://salt-cloud.readthedocs.org/en/latest/topics/install/index.html
* http://docs.saltstack.com/topics/cloud/digitalocean.html
* http://salt-cloud.readthedocs.org/en/latest/topics/rackspace.html
* http://salt-cloud.readthedocs.org/en/latest/topics/map.html
* http://docs.saltstack.com/en/latest/topics/tutorials/multimaster.html

Documentation and Bugs
======================

* http://salt-formulas.readthedocs.io/
   Learn how to install and update salt-formulas

* https://github.com/salt-formulas/salt-formula-salt/issues
   In the unfortunate event that bugs are discovered, report the issue to the
   appropriate issue tracker. Use the Github issue tracker for a specific salt
   formula

* https://launchpad.net/salt-formulas
   For feature requests, bug reports, or blueprints affecting the entire
   ecosystem, use the Launchpad salt-formulas project

* https://launchpad.net/~salt-formulas-users
   Join the salt-formulas-users team and subscribe to mailing list if required

* https://github.com/salt-formulas/salt-formula-salt
   Develop the salt-formulas projects in the master branch and then submit pull
   requests against a specific formula

* #salt-formulas @ irc.freenode.net
   Use this IRC channel in case of any questions or feedback which is always
   welcome
