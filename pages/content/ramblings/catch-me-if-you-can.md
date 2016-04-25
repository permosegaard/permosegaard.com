---
title: Catch me if you can
description: A journey down the rabbit hole of digital forensics
date: 1/1/70
icon: spy
layout: ramblings/post.html
header: Catch me if you can
subheader: A journey down the rabbit hole of digital forensics
lunr: true
code: true
---
Once upon a time there was a webdev, let's call him Timmy. Timmy was a good WebDev - he worked hard, he cared about the
correctness of his code and he tried to help others when they were struggling but Timmy had a secret...

Timmy wasn't confident good when it came to system operations. Deployments filled him with a deep sense of dread so
he always made sure he was too busy to take the work when it came his way. Sadly for Timmy today was the day that he was
the only dev on site and the Marketing Team were demanding updates to the site in the middle of a major sales event.

Timmy bit his lip and decided that today was his day, not only would he do the deployment but he would also master the
demons that plagued his every day at work. He worked through the deployment docs with everything worked as expected. He pressed
his final enter and pulled up chrome, the site was working, and faster than ever! He stood up and patting himself on the back,
decided to take the crumpeled red packet out of his top draw (the one he kept for special occasions) and go for a walk outside to calm down.

Timmy walked back into the office to a sight he had not seen before.. the Sales Director screaming at Marketing. Timmy had a
sinking feeling as he heard the words, "THE SITE IS DOWN, HOW COULD YOU HAVE DONE THIS?! THIS IS THE MOST IMPORTANT DAY OF THE YEAR FOR US!!"
Timmy ran over to help calm down the situation but the anger quickly turned to him, thinking quick he responded with "I ran through our standard
procedure and tested that everything was fine, it must be our Hosting Company, I don't trust them, they've taken down the site before!"

Timmy was sent away to find out what was wrong so he called the Hosting Company and decided that an agressive tone would get things
moving quicker. He got through to an engineer turned it up to 11, screaming about incompetence, service agreements and legal action.
After some time the engineer managed to calm him down so they could work through the issue and it wasn't long before the they
discovered the missing htdocs folder, the engineer asked Timmy if he knew anything about this...

Timmy paused as he looked back through his session logs, his heart sank, he had mad a terrible mistake during deployment.
If anyone found out about this error he would be marched out of the building immediately. Timmy had other plans and he had a good
idea of what was and wasn't logged on the server from his session. He decided to deny everything as he said to himself, "How would they ever know?"
He fired back to the engineer, "NO! and I can see sessions open from your office, it must be one of your engineers!". He feigned anger
as best he could and stormed across the office to the Sales Director and laid it on thick, the Sales Director straight to the MD's office.

This is the part of the story where I get involved. A ticket is esclated up to me by a very worried Account Manager for a "VIP" customer
who had received a call from the MD of the company making accusations of malicious intent on our part and talking about legal action.
I dropped everything and started investigating, it didn't take long to confirm the previous engineer's finding and start the restore process
for the site from yesterday's backups.
It was obvious that someone had made a serious error, htdocs folders don't delete themselves but looking through the logs on the server
wasn't providing any answers. I could see there was 4 sessions open still (including the WebDev's) and bash doesn't write it's history
out to ~/bash_history until the session is exited, we needed to know what had been run in those sessions...

<p><div class="ui styled fluid accordion">
<div class="title"><i class="dropdown icon"></i>Generic guide to working with a live bash process</div>
<div class="content"><div>

<ul><li>In a second terminal, start a bash process as a known user and run a command we can scan for later for testing</li></ul>

<pre><code class="bash">
> bash
user@localhost:~/$ echo test12345
test12345
</code></pre>
<br/>

<ul>
<li>Let's pull the PID of the bash process we wish to probe, you'll probably want to pass into a second grep for the user you want.</li>
<li>Once you have the PID you need to probe the process maps for the memory address for the process heap</li>
</ul>

<pre><code class="bash">
> ps auxf | egrep '^USER|[b]ash'
USER       PID %CPU %MEM    VSZ   RSS TTY      STAT START   TIME COMMAND
user     30318  0.5  0.1  28724  5440 pts/26   S+   18:13   0:00  |   \_ bash

> cat /proc/30318/maps | grep heap
01712000-01932000 rw-p 00000000 00:00 0                                  [heap]
</code></pre>
<br/>

<ul><li>Take the memory addresses you found earlier, prefix them with "0x" and fill in the PID</li></ul>

<pre><code class="bash">
> gdb -quiet --batch --pid 30318 -ex "dump memory process.dump 0x01712000 0x01932000"
</code></pre>
<br/>

<ul>
<li>You now have a memory dump but it's raw bytes from the process so reading it could be difficult, luckily "strings" comes to the rescue</li>
<li>You can read through the dump manually however it can take a while, trying searching for known values to get a head-start</li>
</ul>

<pre><code class="bash">
> strings process.dump | grep "echo test12345"
echo test12345

> strings process.dump | less
</code></pre>
</div></div></div></p>


... Timmy was standing strong and as far as he was concerned his story was water tight. He had triple
checked the server logs to make sure no-one could discover his mistake. Everything was looking OK until he saw an email come through.
He was no longer the owner of the ticket with the Hosting Company but he was still CC'd in on it, the response included ...

```bash
> strings process.dump | grep "/var/www/html"
rm -Rf /var/www/html /cache/*
```
... his heart sank as he realised that his lies were exposed. Timmy knew what was coming next, he put his head in his hands and replayed the day in his mind.

It's never a good idea to lie, especially in a professional setting. Everyone makes mistakes and the faster you own up to an error the quicker it can generally be fixed.

My takeaways from this situation are nothing new but could do with being reiterated one more time.
* Don't be afraid to say no, if you're doing something dangerous you're not confident? Be honest, honestly explain the risks - even when it means taking a dent to your ego.
* Tripple check your work, before *and* after making changes (remember that browser cache's can be misleading)
* Mistakes happen! If you have support and you're honest you may find backups can come to the rescue very quickly in an emergency
* Mistakes happen! Sending people on a wild goose-chase to hide your error will catch up with you eventually.

We were lucky that the user didn't have the forethought to 'kill -9' his bash session but there are times in forensic discovery where
you need to go deeper, given that situation how would you have ascertained the guilty party? Let me know at permosegaard@googlemail.com
