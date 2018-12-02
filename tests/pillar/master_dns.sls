git:
  client:
    enabled: true
linux:
  system:
    enabled: true
salt:
  master:
    enabled: true
    command_timeout: 5
    worker_threads: 2
    reactor_worker_threads: 2
    source:
      engine: pkg
    pillar:
      engine: salt
      source:
        engine: local
    ddns:
      enabled: True
      keys:
        key: 'yEdG9/x8Sb+efi27GyeXNg=='
        name: salt-updates
    reactor:
      dns/node/register:
      - salt://salt/reactor/node_ddns_register.sls
