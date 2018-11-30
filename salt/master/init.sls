include:
- salt.master.service
{%- if pillar.salt.master.reactor is defined %}
- salt.master.reactor
{%- endif %}
{%- if pillar.salt.master.ddns is defined %}
- salt.master.ddns
{%- endif %}
- salt.master.env
- salt.master.pillar
- salt.master.minion
{%- if pillar.salt.master.win_repo is defined %}
- salt.master.win_repo
{%- endif %}
{%- if pillar.salt.master.ssh is defined %}
- salt.master.ssh
{%- endif %}
{#
- salt.master.orchestrate
#}
