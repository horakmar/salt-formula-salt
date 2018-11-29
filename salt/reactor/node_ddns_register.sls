{%- for rec_name, record in data.data.get('net_info', {}).iteritems() %}
{%- for name in record.get('names', []) if '.' in name %}
{%- set hostname, domain = name.split('.',1) %}

ddns_node_register_{{ name }}_{{ loop.index }}:
  runner.ddns.add_host:
  - args:
    - zone: {{ domain }}
    - name: {{ hostname }}
    - ttl: 300
    - ip: {{ record.get('address', '127.0.0.127') }}
    - keyname: salt-updates
    - keyfile: /etc/salt/dns.keyring
    - nameserver: {{ salt['grains.get']('ddns_server', '127.0.0.1') }}
    - keyalgorithm: 'HMAC-MD5.SIG-ALG.REG.INT'
{%- endfor %}
{%- endfor %}
