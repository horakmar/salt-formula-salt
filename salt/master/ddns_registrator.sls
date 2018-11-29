{%- from "salt/map.jinja" import master with context %}
{%- if master.get('ddns:server', False) %}

ddns_registrator_packages:
  pkg.installed:
  - names: {{ master:ddns_pkgs }}

ddns_keys_file:
  file.managed:
  - name: /etc/salt/ddns.keyring
  - source: salt://salt/files/ddns.keys
  - template: jinja
  - mode: 600

{%- endif %}
