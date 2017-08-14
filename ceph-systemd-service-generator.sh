#!/bin/bash
SYSTEMD_ETC_DIR="/etc/systemd/system"
SYSTEMD_USR_DIR="/usr/lib/systemd/system"

# Get cluster name by grabbing it from the config file name
for CONF in /etc/ceph/ceph*.conf; do
  CLUSTER=${CONF##/etc/ceph/}
  CLUSTER=${CLUSTER%%.conf}
done

# Set up 'wants' dir for $CLUSTER.target
mkdir -p $SYSTEMD_ETC_DIR/$CLUSTER.target.wants

for TYPE in mds mon osd; do
  # All daemon targets should be wanted by $CLUSTER.target
  ln -s $SYSTEMD_USR_DIR/$CLUSTER-$TYPE.target $SYSTEMD_ETC_DIR/$CLUSTER.target.wants

  # osd instances are handled by ceph-disk (via system-ceph-slice)
  if [ $TYPE != "osd" ]; then
    # Set up 'wants' dirs for different daemon targets
    mkdir -p $SYSTEMD_ETC_DIR/$CLUSTER-$TYPE.target.wants
    rm -f $SYSTEMD_ETC_DIR/$CLUSTER-$TYPE.target.wants/*

    for DAEMON in $(ceph-conf -c $CONF -l $TYPE --filter-key-value host=`hostname -s`); do
      ID=${DAEMON##$TYPE.}
      # Create 'want' links for all daemon instances to their daemon targets
      ln -s $SYSTEMD_USR_DIR/$CLUSTER-$TYPE@.service $SYSTEMD_ETC_DIR/$CLUSTER-$TYPE.target.wants/$CLUSTER-$TYPE@$ID.service
    done
  fi
done
