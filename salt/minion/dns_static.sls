send_dns_static_event:
  event.send:
  - name: dns/static/records
  - records: {{ pillar.salt.minion.get('dns_static', {}) }}
  - ddns: {{ pillar.salt.minion.get('ddns', {}) }}
