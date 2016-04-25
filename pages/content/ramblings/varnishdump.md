---
title: Peering into Varnish's cache
description: How to pull the cache contents from Varnish using a couple of commands
header: Peering into Varnish's cache
subheader: Viewing cache contents in a couple of commands.
date: 1/1/70
icon: code
layout: ramblings/post.html
lunr: true
code: true
---
Working with websites that get a lot of traffic usually means placing a caching layer in front of your web servers. Years ago this would have been a Squid install but it was never really designed for reverse proxying and would crumble under enough load.</br>
Varnish arose to fill this need in the industry. It has gone from strength to strength since its release and while it is very good at what
it does, it can be a nightmare to diagnose issues with content that's already stored in the cache.</br>
Logging has improved over the years but there have been many times that I wished there had been a mysqldump-a-like available for varnish. Below is a technique I have used in the past to see what's happening inside Varnish.
<br/><br/>


* Let's install Varnish and Apache with Varnish forwarding to Apache for testing

```bash
> apt-get install -y apache2 varnish
...

> sed -i 's/    .port = "8080";/    .port = "80";/' /etc/varnish/default.vcl

> service varnish restart
```
<br/>


* Create a file that we can populate the cache with

```bash
> echo "test12345" > /var/www/html/test.html

> curl localhost:6081/test.html
test12345
```
<br/>


* Dump out the shared memory and scan it for the file created above

```bash
> strings /var/lib/varnish/tester/_.vsm > dump.txt

> egrep -n -A1 "^Start:" dump.txt | grep "/test.html"
154-/test.html

> sed -n '154,/REM_CLOSE/p' dump.txt | less
```
<br/>


This should place you in a "less" session with the details about the request through varnish for the cache entry "test.html" that we created above.<br/>
I have forked the Varnish code base at github to produce the tool listed at the top of this article but the Varnish code is vast and complex beast. Until it's ready the steps above should help you diagnose issues with cache entries.<br/>
If you're aware of a tool that does this natively, have any ideas about one or have any questions then let me know at permosegaard@googlemail.com.
