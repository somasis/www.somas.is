---
title: music library maintenance
description: I have lots of music and I am a cheapskate who will never buy a new hard drive
date: 2021-05-21
aliases:
  - /note-beets-lossless-and-lossy.html
---

I was talking with a friend a few days ago because they posted about how
much space storing music takes up, when I decided that I ought to write
down how I do my music library's organization.

Now, ideally this might not be that interesting, but I don't have much
storage space, and I don't wish to store lossless music on everything. I
just don't have the storage space across all my devices.

```text
somasis ~ ● ssh fort beet stats
Tracks: 11983
Total time: 4.9 weeks
Approximate total size: 329.7 GiB
Artists: 1964
Albums: 984
Album artists: 337
```

What I can do, is store lossless in one place, and then store compressed
copies everywhere else, though. Here's how I do that.

## first you take up a lot of space on a server

When I get my music, I store it in a directory on a server in my home.
This directory is the `source`, "/mnt/raid/library/audio/source".

```text
somasis ~ ● ssh fort tree /mnt/raid/library/audio/source --dirsfirst -d -L 1
/mnt/raid/library/audio/source
|-- rips
|   |-- Various Artists - Hot Wheels Turbo Racing (1999)
|   |-- Various Artists - Inner City Sounds
|   `-- Various Artists - Little Darla has a Treat for You, Volume 30 - Summer 2020
|-- stores-bandcamp
|   |-- ATW - A Small Horse
|   |-- ATW - Mares EP
|   |-- Andrew Lang - Burnt Shades
|   |-- Andrew Lang - From Before
|   |-- Andrew Lang - Momentary Senses
|   |-- Andrew Lang - Strangers EP
|   |-- Karnaboy - Feathers Falling in Slow Motion
|   `-- Men I Trust - Oncle Jazz
[...]
```

And so on.

It is where all the things in the library originate from, in terms of
import location. Additionally, tracking details like if I ripped it from
my CD collection/vinyl collection, or if it was from Bandcamp, helps me
to retrace my steps if I notice issues on a
[MusicBrainz](https://musicbrainz.org) release I committed. Mainly, this
allows for an incremental import, using the [corresponding configuration
options](https://beets.readthedocs.io/en/v1.4.9/reference/config.html#incremental)
in beets, meaning that it won't import from any directories it has
already imported from in the past.

I have a simple `Makefile` for importing, which simply runs...​

<!-- markdownlint-disable no-hard-tabs -->

```makefile
beet-import:
	find /mnt/raid/library/audio/source \
	    -mindepth 2 \
	    -maxdepth 2 \
	    -type d \
	    -exec beet import -tc {} +
```

Again, it's using the `-{min,max}depth` so as to catch all the
categorizing directories (\"stores-\*\", \"rips\"), but nothing under
them.

## actually importing the music

When I get a new music release, I put it in the corresponding source
directory, and run `make beet-import`.

I run the interactive tagger, rather than let it do anything here
automatic, and I run `beet import -t`; so, using \"timid\" mode, to be
even more pedantic. My goal is for beets to be the source of truth when
it comes to what my music library contains. If a single thing is linked
to a release other than what it actually is, it invalidates my trust in
the accuracy of my entire library's tagging. Accuracy is important for
me, as someone who has a lot of music and uses much of it when
_producing_ more music. So, I run it in timid mode and validate the
results myself.

The music is imported to "/mnt/raid/library/audio/lossless". I like to
keep the directory mounted over `sshfs`, so I can access it from
"~/audio/lossless" on my laptop.

## converting the music

The relevant beets `config.yml` snippet:

```yaml
convert:
  copy_album_art: yes
  album_art_maxwidth: 800
  embed: no
  never_convert_lossy_files: yes
  formats:
    opus:
      command: ffmpeg -i $source -y -vn -acodec libopus -ab 96k -ar 48000 $dest
      extension: opus
```

Which is to say...​

- `embed:no, copy_album_art: yes`: No embedding the artwork, it takes up
  more space since it duplicates the art for _every single track you
  store_. Copy it instead, to \"cover.jpg\".
- `album_art_maxwidth: 800`: The cover art for Minecraft, Volume Alpha,
  is 2676x2676. I assure you my phone doesn't need that resolution.
- `never_convert_lossy_files: yes`: No converting files that are already
  a lossy format (which for me tends to be mp3s, because pony music is
  always released in a bespoke fashion).
- Lastly, define how we want to convert our library to `opus`. I use 96k
  Opus, and the `-ar 48000` _looks_ unnecessary, but actually is not:
  it's to make sure I don't have a 96kHz rip of something converted to
  Opus, with the codec happily supporting a sample rate that large. So
  just homogenize everything down to 48k, Opus's default sample rate.

Which brings us to the second `Makefile` target:

```makefile
beet-convert:
	beet convert -a -f opus -y
```

I wish I could just stop there and say that's how I maintain the two
copies of my library, but alas. We have arrived upon the first problem
with `beet convert`.

## duplicates and workarounds, or, the important headache you'll eventally get

Though [beets's homepage](https://beets.io/) proudly displays the
[`beet convert`](https://beets.readthedocs.io/en/v1.4.9/plugins/convert.html)
plugin for transcoding audio to any format desired, it does not do the
upkeep of maintaining a library's _structure_ in the process as well.

The problem lies in removing and renaming tracks. beets will shift files
in your library directory (which in my case is the lossless directory)
without issue most of the time, but it is not smart enough to replicate
those changes on the libraries maintained with `beet convert`

Really, the main problem is that `beet convert` (and
`beet alternatives`) only do the work of creating the structure\-- once
folders change, filenames change, the problem is then that you have
duplicates, and you'll have the converted library structure fall out of
sync over time if you want to keep the same directory
structure.[^structure]

[^structure]:
    TODO: another solution I've wondered about is just completely eschewing
    duplicating the folder structure,
    and just doing something like naming files and directories
    after their MusicBrainz release IDs, perhaps.
    Since most music players can just read the tags,
    and don't rely at all on structure,
    this wouldn't be that big of a problem I imagine.

As of now, I fix this problem with a little script named [`beet-rmdupes`][beet-rmdupes];
it also requires the [`mimefilter`][mimefilter] script in my `~/bin` as well.
It's a little wonky in terms of false positives when it comes to beets'
asciification, for reasons I have not yet figured out.

[beet-rmdupes]: https://github.com/somasis/me/commit/13e74a56a636c691d03b9edc1adce275bb28afd5/bin/beet-rmdupes
[mimefilter]: https://github.com/somasis/me/commit/810387ef63a19c509411733b98f19e2eb61c40b1/bin/mimefilter

## so yeah

This is essentially the hard parts. The rest is pretty standard beets
configuration, and the documentation is _otherwise_ excellent, except
for these particularly irritating pitfalls.

beets does...​ a _staggering_ amount, and without choking as hard as it
could. I've really considered writing my own music managing utility as
of late but I just haven't had the motivation to uproot my library
again.

However, there's [bits] and [pieces] laying around...​ someday.

[bits]: https://github.com/somasis/me/commit/4989c360786a7eb522a9d83d1aa0848e4cef7a24/bin/envtag
[pieces]: https://github.com/somasis/me/commit/4989c360786a7eb522a9d83d1aa0848e4cef7a24/bin/envtag-format
