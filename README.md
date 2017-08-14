# Systemd script for CEPH object storage

**ceph-systemd-service-generator.sh** is a systemd [generator](http://www.freedesktop.org/wiki/Software/systemd/Generators/) script which links Ceph systemd targets based on Ceph daemons present on current node. It supports multiple clusters on the same node.

The idea is simple - let "systemctl daemon-reload" do all the job for us.

**NOTE** The original version form which this repo is forked tries to control the creation of all osd/mon/mds units and targets.  However many of these are now delivered by theceph packages,or dynamically created (see e.g. ceph-disk@.service)
Now, this generator serves to simply link all MDS and MON daemon instances to a daemon target, and link all targets to a top-level `ceph.target`

**How to install it**:
> ```This script must be placed under /usr/lib/systemd/system-generators folder. After that "systemctl daemon-reload" must be issued for systemd to execute generator script. The script gets executed every time systemd is 'daemon-reload'ed or at host boot time before any other service gets loaded (see systemd generators link above).```

**How to use it**:
Assuming cluster name is "ceph":

Stop mon.node1:
> ```systemctl stop ceph-mon@node1```

Start all MONs on current host:
> ```systemctl start ceph-mds.target```

Stop all ceph daemons on current host:
> ```systemctl stop ceph.target```

Put Ceph completely to autostart:
> systemctl enable ceph.target
