{%- set ddns = data.data.get('ddns', {}) %}
{%- for zone_name, zone in data.data.get('records', {}).iteritems() %}
{%- for record in zone %}

ddns_record_{{ zone_name }}_{{ loop.index }}:
  runner.ddns.create:
  - args:
    - zone: {{ zone_name }}
    - name: {{ record['name'] }}
    - ttl: {{ ddns.get('ttl', 300) }}
    - rdtype: {{ record['type'] }}
    - data: {{ record['value'] }}
    - keyname: {{ ddns.get('keyname', 'salt-updates') }}
    - keyfile: /etc/salt/ddns.keyring
    - nameserver: {{ ddns.get('server', '127.0.0.1') }}
    - timeout: 10
    - keyalgorithm: 'HMAC-MD5.SIG-ALG.REG.INT'
{%- endfor %}
{%- endfor %}
