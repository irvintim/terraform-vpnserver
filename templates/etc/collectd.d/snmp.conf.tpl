LoadPlugin snmp

<Plugin snmp>
	<Data "keepalived_instance_state">
		Type "gauge"
		Table false
		Instance "keepalived_instance_state"
		Values "KEEPALIVED-MIB::vrrpInstanceState.1"
	</Data>
	<Data "keepalived_initial_state">
		Type "gauge"
		Table false
		Instance "keepalived_initial_state"
		Values "KEEPALIVED-MIB::vrrpInstanceInitialState.1"
	</Data>
	<Data "keepalived_wanted_state">
		Type "gauge"
		Table false
		Instance "keepalived_wanted_state"
		Values "KEEPALIVED-MIB::vrrpInstanceWantedState.1"
	</Data>
	<Host "localhost">
		Address "127.0.0.1"
		Version 2
		Community "${snmprocommunity}"
		Collect "keepalived_instance_state" "keepalived_initial_state" "keepalived_wanted_state"
	</Host>
</Plugin>
