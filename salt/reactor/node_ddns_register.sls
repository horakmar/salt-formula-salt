{%- set ddns = data.data.get('ddns', {}) %}
{%- for rec_name, record in data.data.get('net_info', {}).iteritems() %}
{%- for name in record.get('names', []) if '.' in name %}
{%- set hostname, domain = name.split('.',1) %}

ddns_node_register_{{ name }}_{{ loop.index }}:
  runner.ddns.add_host:
  - args:
    - zone: {{ domain }}
    - name: {{ hostname }}
    - ttl: {{ ddns.get('ttl', 300) }}
    - ip: {{ record.get('address', '127.0.0.127') }}
    - keyname: {{ ddns.get('keyname', 'salt-updates') }}
    - keyfile: /etc/salt/ddns.keyring
    - nameserver: {{ ddns.get('server', '127.0.0.1') }}
    - keyalgorithm: 'HMAC-MD5.SIG-ALG.REG.INT'
    - timeout: 10
{%- endfor %}
{%- endfor %}
