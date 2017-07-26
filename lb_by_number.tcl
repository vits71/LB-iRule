when CLIENT_DATA {
                                        # get number of active nodes in a pool
    set num_active_nodes [active_members [LB::server pool]]
##    log local0. "RADIUS LB: num of active nodes: $num_active_nodes"
                                        # stickyness makes sense only if there is more than 1 node
    if {$num_active_nodes > 1} {
                                        # calculate a pool member number based on calling_station_id's last 9 digits modulo number of active pool members
                                        # this approach should ensure enough entropy. If it's not, more complex calculation must be used
        set last_9_digits [string range [RADIUS::avp 31 "string"] end-8 end]
##        log local0. "RADIUS LB: last digit caller id $last_9_digits"
										# avoid interpreting number as octal
		scan $last_9_digits %d last_9_digits										
                                        # get a name of an active pool member
        set selected_node [lindex [active_members -list [LB::server pool]] [expr {$last_9_digits % $num_active_nodes}]]
##        log local0. "RADIUS LB: selected node: $selected_node"
                                        # select a pool member
        if { [catch { pool [LB::server pool] member [lindex $selected_node 0] [lindex $selected_node 1]} err_msg]} {
            log local0. "RADIUS LB ERROR: member [lindex $selected_node 0] [lindex $selected_node 1] cannot be selected, $err_msg"
            return
        }
    }
}