---
title: A saner MySQL default configuration
description: A saner MySQL configuration including replication
header: Fixing MySQL's insane defaults
subheader: It's time to fix a decades worth of pain and misery.
date: 1/1/70
icon: database
layout: ramblings/post.html
lunr: true
code: true
---

MySQL's life has definitely been an eventful one, starting life simply and building to an eventual sale to Sun for $1B.
A lot of hate towards it was due to it's stock config making some truly insane choices (inefficient, lacking strictness, low limits, etc).
Had it shipped with more sensible defaults and ideally a simple tuner it would likely have seen better usage though the flip side to
that would've seen a lot of "consultant" not necessary.<br/>
Below I've listed some of the defaults I use, I would recommend you read about and test the changes before you put them into a live environment
but for the most part they should be good to go.

Documentation for the changes is available at http://dev.mysql.com/doc/refman/5.5/en/server-system-variables.html - use the version that matches your MySQL version.

```ini
default-storage-engine=InnoDB

innodb_strict_mode=ON
sql_mode = 'STRICT_ALL_TABLES'

skip-name-resolve

autocommit=0
query_cache_type=0
thread_cache_size=4
max_connections=500
collation_server=utf8
max_allowed_packet=1G

log_error
slow-query-log=1
long_query_time=5
log-queries-not-using-indexes=YES

sort_buffer_size=16M
join_buffer_size=16M

tmp_table_size=128M
max_heap_table_size=128M

innodb_file_per_table=ON
innodb_sort_buffer_size=16M
innodb_thread_concurrency=4
innodb_buffer_pool_size=256M
innodb_flush_method=O_DIRECT
innodb_flush_log_at_trx_commit=2
```
<br/>


Replication is a subject that comes with a lot of complication, these defaults should help you avoid some of the issues that typically crop up but you will need to spend some time reading the documentation for replication at the [mysql site](//dev.mysql.com/doc/).</br>
Documentation about the options listed below is available using the documentation link at the top of this page.

```ini
log_bin
relay_log
log_slave_updates

server-id=X
sync_binlog=1
binlog-format=MIXED
expire_logs_days=10
max_binlog_size=100M
max_relay_log_size=100M
auto_increment_offset=X
auto_increment_increment=X
slave_max_allowed_packet=1G
```
<br/>

One day I will get around to writing a tool that integrates a sane default like the above with a tuner like mysqltuner.com, maybe you've done that already or have some great ideas about it?
Let me know at permosegaard@googlemail.com, maybe we can work together to build something beautiful!
