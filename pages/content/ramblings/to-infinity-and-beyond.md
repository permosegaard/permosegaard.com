---
title: To Infinity and Beyond
description: Working with disposable VMs at scale? Let's swap some consistency for speed.
header: Swapping consistency for speed
subheader: Let's learn how to make your data disposable!
date: 1/1/70
icon: dashboard
layout: ramblings/post.html
lunr: true
code: true
---

<p align="center" font-size="50px;">*** ∗∗∗THIS WILL EAT YOUR DATA, ONLY DO THIS IF YOU ARE SURE OF THE CONSEQUENCES∗∗∗ ***</p>
<br/>

Now that the scary warning's out of the way we can be honest. There are plenty of situations where using the
changes below can be appropriate especially given the recent popularisation of immutable infrastructure.

I typically use these changes on throwaway vagrant machines where you don't want to burn cycles on your expensive SAN
for VMs that can be redeployed in seconds.

Some examples of the use-cases that I have found to be appropriate:
* Throwaway development machines, esp. fast iteration docker/vagrant deployments
* Overzealous analytics storage that's queried at most once every 6 months
* Recreation of large envrionments for debugging purposes
* Frozen VMs that automatically rollback on reboot
* Replicated intermediatary data storage that filters & passes out to slower and more reliable storage (read data proxy)
* A machine in a set which has a config that's stored in chef/puppet/etc. and can be redeployed in seconds if there's an issue
<br/>

### Kernel
* Increase the amount of dirty blocks required before flushing
* Increase the amount of RAM used for dirty block storage
* Increase the timeout for dirty blocks to be flushed

```bash
> cat /etc/rc.local
echo 50 > /proc/sys/vm/dirty_ratio
echo 50 > /proc/sys/vm/dirty_background_ratio
echo 60000 > /proc/sys/vm/dirty_expire_centisecs
echo 60000 > /proc/sys/vm/dirty_writeback_centisecs
```

Documentation can be found at https://www.kernel.org/doc/Documentation/sysctl/vm.txt
<br/><br/>

### Filesystem
* Disable file and folder access time updates
* Disable journal and turn up the flushing internal
* Changes /dev/vda's scheduler to NOOP

```bash
> cat /etc/rc.local
/bin/mount -o remount,noatime,nodiratime,nobh,nouser_xattr,barrier=0,commit=600 /
echo noop > /sys/block/vda/queue/scheduler
```

Documentation can be found at http://linux.die.net/man/8/mount
<br/><br/>

### Mysql
* Disable checksumming
* Disable flush calls for writes or transaction commits
* Disable doublewriting
* Enable concurrent inserts for MyISAM with table holes

```bash
> cat /etc/mysql/my.cnf
innodb_checksums=0
innodb_doublewrite=0
concurrent_insert=2
innodb_flush_log_at_trx_commit=0
innodb_flush_method=nosync
```
Documentation can be found at http://dev.mysql.com/doc/refman/5.5/en/server-system-variables.html
