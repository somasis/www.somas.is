---
breadcrumbs: <br/><a href='notes.html'>notes</a>
title: Understanding beets, the music organizer
description: An attempt to explain how beets works and why it can be so confusing.
date: 2025-11-02
bluesky-post: https://bsky.app/profile/somas.is/post/3m4pgyetnus25
---

[old post]: https://somas.is/note-beets-lossless-and-lossy.html
[beets]: https://beets.io/

A few years ago now ([in 2021][old post]),
I wrote about how I managed my music library.
I still use [beets] years later, except now, I use it quite happily.
This is different from years ago, because, if read that old post,
there's quite a lot of kvetching near the end in which I do the usual dance
of suggesting that beets does too much, and that I wish I could just write my
own music organizer.

Why store music metadata in a database when there's tags?
Why not just use the tags, after all?
Well, because beets exists
to try and address the very same problems of un-queryability and inconsistency
which crop up when you're dealing with a music library full of tags.
Every single music player more complex than Winamp
is basically just an interface on top of an index of your music library's tags,
when you get down to it.
And if you're an oldhead, this is more or less what made iTunes so revolutionary
when it came to music organization.

Anyway, I never followed through on that threat to write my own organizer,
because I just don't have the patience (and the knowledge, frankly)
for the task.
But what I have learned is that a lot of my frustrations with beets
stemmed from me holding it wrong and misunderstanding some really basic
concepts underpinning the whole program.

For the record, I'm not a beets developer
(though I have filed a few issues, and submitted some minor pull requests).
I do not claim to have a thorough understanding of the codebase and its
inner workings;
all of this explanation is based on my years of using it
and my attempt over the last year or two
to really pour over the documentation more closely
and understand how this thing works,
instead of just getting frustrated and walking away from it.
I welcome any corrections or feedback from those involved in its development.

So here's an attempt at a more bottom-up explanation of how beets works,
to see if I can save other people the confusion
that I went through for a frustratingly long time.

## The main idea behind beets

When you're using beets,
the database is the source of truth for your music library's metadata.
What this means in more concrete terms,
is that the database has a record for each file in your library directory,
and the fields set in each file's record are the source of truth
for each audio file's tags.

"Field" as a term is always concerned with the library database,
and "tag" is always concerned with music files.
Fields are stored in the database, and tags are stored in the files.
These terms are use extensively throughout beets documentation and
so you need to keep this distinction in mind,
otherwise the documentation will seem very vague,
and the operation of beets will confuse you at some point or another.

The database consists of albums and items (or tracks).
Album and item field values
do not necessarily have to correspond to their file's tags.^[
In fact, due to variations in how music formats store their tags,
they'll often differ in some way
if you actually compare a file's tag values to its field values.]

## Explaining the interface

The actual interface beyond importing in beets
(the `update`, `move`, `copy`, and `write` subcommands, among others)
has always been a little hard to grasp for me.
If we can understand the interface though,
it will help to understand the "flow" of metadata through beets,
and overall, help our understanding of what all it does.

### Importing

The most complex part of beets really is just the importing process,
but for good reason,
because it is really where all the magic of the program is contained.
So I'll start by explaining the importing process.

When you execute `beet import <directory>`, it

1. fetches metadata from sources like MusicBrainz, etc. by

   a. looking at the existing tags applied to audio files within `<directory>`,

   b. putting together a search query based on those tags,

   c. and finally, asking you to pick a matching album from those sources.^[
   (all this behavior is turned off with `--noautotag`)]

2. Then, once the file importing really starts,

   a. it creates records for each file being imported,

   b. creates a record for the album represented by all those files,

   c. sets the fields for each file record based on the file's tags,^[
   Meaning that tags like comments
   will be available in the fields by default.]

   d. and (if auto-tagging, which is the default behavior)
   updates the fields for each file based on the fetched metadata,
   replacing tags for which there is corresponding fetched metadata with
   that fetched metadata.

3. Finally, it writes the fields to the audio file's tags.

### Managing imported files

Some time passes, and in your music player,
perhaps you've done some things
like edit incorrect lyrics,
set track ratings,
or whatever.
But if you start querying the beets library,
you might at first be surprised that your library does not have any the changes
that you made to the file tags.^[
Well, at least you might be surprised if you didn't first understand the
distinction between fields and tags...]
In this case, you want to use `beet update`:
it will `update` fields in library based on changes in audio file tags.

When you do `beet update [query]`, it

1. compares file tags to their corresponding fields,

2. and when the tags differ from the fields,
   it replaces the field values with the tag values.

It does _not_ update the field values or tag values
for any changes from the metadata source used during importing.^[
If you're looking for this functionality,
it is implemented by the `mbsync` plugin and its subcommand.]
It is a one-way operation:
tags are compared with fields,
and where the two differ,
tag values replace field values.

When you do `beet write [query]`, it

1. compares file tags to their corresponding fields,

2. and when the tags differ from the fields,
   it replaces the tags with the values of the fields.

These two operations are basically opposites of each other.

`beet modify [query] <modifications>` edits fields matching `[query]`.
Plus (by default), it will write modified field metadata to the file tags.
Thus, if you are primarily editing your library metadata through `modify`,
you might not find yourself using `update` and `write` that often.
But if you ever modify your tags out-of-band (i.e., via a music player),
you'll want to understand `update` and `write`.

There is no form of bidirectional syncing when it comes to beets.
Before I understood really what `update` and `write` were for,
I always found it strange that `update` didn't just take the changed tags,
put them in the database,
and then write all the metadata after updates back to the file;
why split up the operations of updating the library from tags and writing tags?

Notice how this criticism
doesn't really make sense in light of all this groundwork? ;)

### Moving imported files around

At some point, you might decide that you want to change how you structure
your music library directory.
So you might change the `paths.default` option in your beets config.
Changing this configuration setting does not immediately move your files to
their new intended locations;
in fact, it will only apply this new path to any future albums you import.
So how do you go about moving your whole library to the new structure?
This is where `beet move` comes in.

When you run `beet move [query]`, it just checks that files matching `[query]`
have paths that match what the beets configuration says their paths should be.
If they differ, it does whatever needs to be done to make that file be at
the new configured path, making directories and renaming files.

## Conclusion

[Music Player Daemon]: https://www.musicpd.org/
[Cantata]: https://github.com/nullobsi/cantata
[gmusicbrowser]: https://gmusicbrowser.org/
[Clementine]: https://www.clementine-player.org/
[Audacious]: https://audacious-media-player.org/
[cmus]: https://cmus.github.io/
[Noise]: https://github.com/elementary/music
[Quod Libet]: https://quodlibet.readthedocs.io/
[fooyin]: https://www.fooyin.org/
[Elisa]: https://apps.kde.org/elisa/

Beets is a difficult program to competently use
primarily because of the problem space it attempts to cover.
Music library organization is a surprisingly difficult problem
once you really think about how to do it.
If memory serves,
among all the different music players I've tried over the years,^[
[Music Player Daemon] (probably my most-used one over all the years)
with [Cantata] as the primary MPD client (it's still my favorite MPD client),
[gmusicbrowser] (a real deep-cut of a music player
written in Perl,
that I still kinda miss sometimes),
[Clementine],
[Audacious],
[cmus] (for a time),
[Noise] (excuse me, I guess it's Pantheon Music now; it was Noise back when I used it),
[Quod Libet] (still probably one of the better music players out there!),
[fooyin],
and now [Elisa].
]
it's always seemed like every music player
has had a different way of tackling organization at the file and tag level,
and this has always made interoperability between and preservation of metadata
between players annoyingly difficult.
It's understandable why it's so enticing
to just give up on consistent and well-formed metadata
and the idea of automatic organization of your music library,
in favor of tagging _all of it_ manually and organizing it yourself,
or just hoping your music player will smooth over all the mess
so you can forget about it.
Beets is essentially the state of the art
for how thoroughly it tries to solve this problem,
while being
as accomodating to different users' different preferences as possible.

Hopefully this was enlightening
and helped to clarify some of why Beets is the way it is
and why I still use it after all these years,
long trapped in a love-hate relationship with it,
now happily attached to it.

Thanks for reading.

## Postscript: my music listening setup

I use [Elisa] for actually playing my music these days,
mostly because I like its interface the most and its responsive design,
as well as the focus it gives to album art.
I would be lying if I said I was completely satisfied with it,^[
It struggles with gapless playback at times,
it doesn't really have a great shuffle mode,
it's not as flexible as a Music Player Daemon server and a client,
blah blah blah...]
but it gets the job done, and I love listening to music on my puter.

These days,
all my music is stored locally on my computer, in Opus (96k) format,
converted by beets at time of import.
The library is also available on a server I pay for,
and so my phone streams my music library (and caches it very liberally)
over a WebDAV store.

When I wrote that [old post] I mentioned in the beginning of this post,
I talked about using beets' `convert` plugin to preserve FLAC source files
in a beets-managed library,
and then I'd sync a converted copy of my music library (using Syncthing)
to my phone and computer.
This caused a lot of problems
and really negated a lot of the benefits
of using beets for preserving and managing library metadata;
ratings were never saved properly from my music players
because there was no clear way to synchronize tags
from the converted Opus files to the FLAC files managed by Beets.
I just don't need an organized lossless 24bit 96k FLAC of my music library, man.
It's a pain and it's just a waste of time and space if you're only listening
to music.
I keep the source files in a bigger storage location anyway.

Now, I just keep Opus in my music library,
and I have `import.copy: yes` set in my beets config,
which means the FLAC source I import from
is safely preserved in the location I import it from.
Opus is great
and it's the way of the future
and MP3s really ought to be dead by now,
and I don't really care if I eat my words on this in the future
when a new compression algorithm comes out that's better than
the already astonishing sound quality to file size ratios
that Opus is able to produce today.

I also use my phone quite often to play music
(particularly at night when I'm in the bed,
or in my car,
or when I just need to be away from the computer but need some chunes).
On my phone, I use [Symfonium],
which is an excellent (paid) Android application.
I used to use [Poweramp], which got me through my undergraduate years,
but eventually I was interested in something that had a different interface,
and that would support non-local music libraries.
Both are great, it just depends on what you need out of your music player.
Symfonium is superior if you want to go crazy customizing the user interface,
but particularly so if you want to stream your own collection from sources like
a WebDAV location (which is what I do),
or from a Jellyfin server,
or a Subsonic server,
but it works great with a locally-stored music library too.

I scrobble all my music to my [ListenBrainz] and my [Last.fm].
My Last.fm history goes back a really long time and I just don't know if I can
ever bear to get rid of my account; it's probably the oldest online account
I still actively use.

I have some tools that I wrote for common tasks I often need to do to my
beets library that are in my [~/bin].

[Last.fm]: https://www.last.fm/user/kyliesomasis
[ListenBrainz]: https://listenbrainz.org/user/Somasis/
[~/bin]: https://github.com/somasis/puter/tree/main/bin
[Symfonium]: https://www.symfonium.app/
[Poweramp]: https://powerampapp.com/
