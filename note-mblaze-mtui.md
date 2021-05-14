title: mblaze mail client design notes
summary: what if god was a mail client
date: 2021-05-14

[mblaze]: https://github.com/leahneukirchen/mblaze
[Maildir]: https://en.wikipedia.org/wiki/Maildir
[himalaya]: https://github.com/soywod/himalaya
[snooze]: https://github.com/leahneukirchen/snooze
[mvi]: https://github.com/leahneukirchen/mblaze/blob/master/contrib/mvi

A long-standing idea I've had is a mail client based around [mblaze][mblaze], a beautiful little set
of tools by my friend Leah that automates the process of working with [Maildir] directories and the
messages within them. In my mind, this would be a really beautiful piece of software: you've got the
disparate parts sectioned off into small little tools, things are oriented around Unix pipes and
never escape the realm of filesystem-as-database. A graphical interface doesn't trouble itself with
implementation of things, and lets them be handled by something more knowledgable and purpose-built.

Having an idea for a tool for a long time seems to rarely mean that a tool is one I will end up
making... I do like imagining designs, in absence of implementation, though.

There's a project that came into existence called [himalaya], which is similar to what I'm desiring,
I think. However, I think it's prioritizing external usability over internal flexibility, as shown
by attention to supporting IMAP, troubling itself with implementation of protocol (though, it's
using a Rust crate for IMAP support I believe). Supporting both use as a traditional client as well
as a command line program with a subcommand design pattern is great, though.

I think that creating something that is a client made from those small purpose-built parts like
mblaze though, is more interesting from a conceptual standpoint. Regardless, himalaya is quite cool
and I'm excited to see where it goes.

Anyway, here's my idea:

`mtui(1)` is a command that starts a specialized `tmux(1)` session.

1. The session begins with a window for each of your accounts, containing a list of the mails in
   the inbox directory. `mdirs ~/mail/*@*/INBOX | mlist | mscan`?
2. A fuzzy finder allows for quick browsing through the list. Or perhaps, a fuzzy finder only
   begins to run once you start typing a search query? I think a finder of that nature would
   definitely play a role in navigating lists, regardless. Hmm.

    - `mless(1)` and an mblaze contrib script, [`mvi`][mvi], both approach this sort of usage,
      at least the list navigation part. They act alike, but `mless` works by utilizing `$LESSKEY`,
      `$LESSOPEN`, things like that. `mvi` works differently by actually drawing the whole interface
      itself; `dd(1)` for reading in keys, `stty(1)`, `tput(1)`, all that mess. Interesting, but the
      interface logic looks a little convoluted to me, unavoidable in part since it's POSIX sh.

3. Messages are viewed in `mless`, opened in a pane (or perhaps another window).
   For something a little more spicy, perhaps in a session of your `$EDITOR` of choice, replies
   created by editing the message in the editor...?
4. Mail synchronization is done out of the client, unrelated to the operation of it, `mblaze` has
   never been designed to handle that. Could listen to `inotify(7)` to update list windows, though.
   For example, I use `mbsync` on a [`snooze(1)`][snooze]
