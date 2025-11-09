---
title: Using NixOS with musl libc and LLVM
description: # TODO
date: 2025-11-04
params:
  bluesky: # TODO
draft: true
---

[Gentoo]: https://gentoo.org
[Exherbo]: https://exherbo.org
[Paludis]: https://paludis.exherbo.org

Years ago, I was a developer for the [Exherbo] Linux distribution,
a distribution made by a group of former [Gentoo] Linux developers,
though honestly I'm not entirely sure of the history.
My understanding is that there was an alternative package manager project
created by one of the Gentoo developers called [Paludis],
which implemented a different interface (implemented in C++)
for installing packages from Gentoo's ports collection.
I could go on, but this isn't what I intended to focus on today, so I digress.

I had never used Gentoo when I first started using Exherbo,
but as source-based distributions do with any novice Linux user,
it gave me an opportunity to become intimately aware with the building blocks
of a standard Linux system.
One of the common things about Linux distributions is that most of them are,
like that old copypasta jokes, GNU/Linux distributions.
They use GNU coreutils, they use the GNU C Library (or glibc),
and they use GNU Bash, and so on;
GNU software is just really woven into the fabric of the common Linux userland,
for reasons I don't care to go into.

Some time after I became a developer,
I became interested in the wave of
non-copyleft[^copyleft] software
that was coming out at the time,
like [toybox] (an alternative to Busybox),
and [musl libc] (a lightweight alternative to glibc and others,
more amenable to static linking among other things).
I suppose I had philosophical objections to copyleft,
having become intrigued by those libertarian ideas
that _anyone_ (even companies making money) should be able to use free software.
Looking back, I was just young enough that I thought that an "impenetrable"
block of text like the GPLv2 (and its successor the GPLv3) was worth replacing,
on the basis of removing restrictions on use and forking alone.
I was very interested in the ideas behind BSD and their non-copyleft tradition.
And I had heard lots about how GNU software was bloated
(mostly from reading stuff from the [Suckless] crowd),
and found it convincing.

[^copyleft]: "Copyleft" licenses like the GNU Public License, etc.

Anyway, all that was back in 2015 I think.
These days, I don't concern myself with these issues so much.
I think I believe in the ideals of Free Software, and the ideas
represented in a legal document like the GPL
(especially the GPLv3, with its anti-TiVoization clause),
because at this point I've seen what the availability of non-copyleft
software has helped proliferate in terms of the locking down of users' devices,
and I think open source software really ought to have some more teeth
against the profit motives of companies
and the use of free software for nonfree aims.
That said, I don't consider myself... naive enough, I suppose,
to think that it's really the fault of copyleft software
that free software has become a somewhat politically neutered phenomenon,
visible in the replacement of free (as in libre) software
with simply "open source".

My philosophical reasons always were just justification for a simpler reason:
why not be able to use alternatives?
Why not be able to replace the fundemental projects
that power my computer every day,
just as (relatively) easily as I was able to replace the OS that came with it?
I consider the goal of using Linux,
and using free sofware over non-free alternatives,
to be primarily one about exerting control over my devices.
It's about the preservation of agency and all the beautiful opportunities for
self-education that a machine you can take apart, put back together, run your
own software on, what have you, presents to users.

In the time since then, I've become a happy user of [NixOS], especially for how
it presents so much flexibility to the user.
It does a things better, philosophically speaking, than Exherbo does,
especially when it comes to this one:
["we expect users to take part in the development"][users-are-developers].
This is definitely the case with NixOS, for better or worse,
because the Nix code is so often the thing you need to look at
in order to use and configure NixOS, and crucially,
_actually understand what's going on when you encounter an error when modifying
your system configuration_.
This is a problem in some ways
because it really raises the bar of entry to using NixOS.
But, on the flip side,
it also gives a new user many opportunities to learn new things:
it presents opportunities to learn how Linux works,
to learn the fundementals of functional programming languages (like Nix) work,
and it makes experimentation with how you use your computer a painless endeavor.
Learning begets learning.

--

[exherbo-bootstrapping]: https://www.exherbo.org/docs/bootstrapping.html
[NixOS]: https://nixos.org
[users-are-developers]: https://www.exherbo.org/docs/expectations.html

One of the things I became interested in doing while I was an Exherbo developer
was trying to bootstrap a non-glibc based Linux system.
I had never tried something like that, but I considered myself to be smart enough
to figure it out, and well, [I did manage to do it][exherbo-bootstrapping].
