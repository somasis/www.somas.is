---
title: Organizing your Nix configuration without flakes
description: or, how to get the good parts of Nix Flakes without the bad parts
date: 2025-10-17
params:
  bluesky: https://bsky.app/profile/somas.is/post/3m3ghkp7jd22b
aliases:
  - /note-organizing-nix-configuration-without-flakes.html
---

[flakes-experiment]: https://samuel.dionne-riel.com/blog/2023/09/06/flakes-is-an-experiment-that-did-too-much-at-once.html
[flakes-feature-freeze]: https://wiki.lix.systems/books/lix-contributors/page/flakes-feature-freeze#bkmrk-design-issues-of-fla
[flakes-stabilization-proposal]: https://wiki.lix.systems/books/lix-contributors/page/flake-stabilisation-proposal
[pinning-nixos-with-npins]: https://jade.fyi/blog/pinning-nixos-with-npins/
[not-channels-vs-flakes]: https://samuel.dionne-riel.com/blog/2024/05/07/its-not-flakes-vs-channels.html
[npins-module]: https://github.com/somasis/puter/blob/main/modules/nixos/npins.nix
[puter]: https://github.com/somasis/puter
[niv]: https://github.com/nmattia/niv
[npins]: https://github.com/andir/npins
[lon]: https://github.com/nikstur/lon

Once, I used [Flakes](https://wiki.nixos.org/wiki/Flakes).
Then, I realized how much they actually complicate things.
Which is to say, this week I decided to rip out all the Flakes stuff from my
[dotfiles][puter].
This is a big event, I suppose, because Flakes were the first thing I had an
opinion about when I started using NixOS in 2022,
and I figured they were the way of the future and that they'd not be experimental
eventually and that I might as well learn that now while I'm getting started.
It is now 2025, and I am unemployed and trying to find some way into tech pretty
unsuccessfully so far, having blown off grad school; as you can imagine, I have lots of free time.

Flakes are good for finding a place to get your footing when starting to learn
the Nix language—there are in fact, _too many_ places to start from in Nix—and
they acclimate you to a purely declarative way of building your machine very
quickly, with a prescribed notion of how to organize it.
[There are a lot of good and interesting features involved in the overarching
thing that is Flakes.][flakes-experiment]

They're also bad for learning the Nix language, because they add a layer on top
of an already complex language to learn.[^learning]
The reasons that we have Flakes make lots of sense,
but the implementation of it, as it stands now,
is [kinda already a form of technical debt][flakes-feature-freeze].

[^learning]:
    Plus, if you've oriented your understanding of Nix around flakes,
    some parts of the language will look kinda weird comparatively,
    and you'll probably avoid learning how to properly "hold" the tools that
    Nix gives you, usually trying to do _everything_ through the mechanisms
    that Flakes provide, when they could be done much more simply.

### The good parts of Flakes

1.  They provide a schema for accessing parts of a project
    (`nixosModules`, `nixosConfigurations`, `packages`, etc.), whereas
    it feels like every module structures everything differently in lieu
    of a schema,
2.  they make it easier and more explicit when you declare a project's
    dependencies, and give tooling for tracking those dependencies in
    version control (like `nix flake update --commit-lock-file`),
3.  they give us an okay/fine built-in alternative to Nix
    Channels,[^channels] which we ought to discourage using because
    Channels (as demonstrated by resources like the NixOS Manual)
    are a very undeterministically designed concept that sticks out
    like a sore thumb once you're familiar with the ideas behind Flakes
    at least,
4.  and they present an obvious entry-point to a Nix project, whereas
    otherwise the entry-point could be basically anything.[^default.nix]
    But if every project has a `flake.nix`, then you could just expect
    your NixOS module somewhere like `project.nixosModules.default`,
    which sounds a lot better.

[^channels]:
    And when I say \"channels\", to be precise,
    I'm referring to the model of dependency management implemented with
    `nix-channel`, where a channel (like `nixpkgs`, or `home-manager`)
    is configured _by the system environment, and not the Nix stuff being built_,
    to point to the contents of a URL like
    `https://nixos.org/channels/nixos-25.05/nixexprs.tar.xz`
    or `https://github.com/nix-community/home-manager/archive/master.tar.gz`,
    then being propagated to tools like `nixos-rebuild` and `nix-build`
    and so on at the command line via the environment variable `$NIX_PATH`,
    which is then looked up when the code says `import <nixpkgs> {}`...​
    [See here for a better explanation.][not-channels-vs-flakes]

[^default.nix]:
    `default.nix` could be an attribute set, or one single
    `stdenv.mkDerivation`. Or maybe the project doesn't even provide
    a `default.nix` and you need to `import "${project}/nixos-module.nix"`
    instead...​

### The bad parts of Flakes

1.  the Flake schema is very limited and it is **under**-standardized,
    and sometimes it feels like every module structures everything a
    little differently, because the schema and implementation hasn't
    kept up with its users, which, granted, is a problem that could be
    solved if Flakes were
    [stabilized, and the schema upgraded][flakes-stabilization-proposal],
    but unfortunately,
2.  Flakes seems to be stuck in a state of eternal experimental status,
    and many stakeholders involved seem intent to just run with it now,
    especially because company projects, through sheer labor power and
    marketing, can divide an ecosystem very easily, particularly if the
    goal is a paycheck and not a community authored, well-designed
    language, but I digress;
3.  as a result of these other factors—Flakes' lack of evolution since
    being proposed, and its permanent experimental state—eventually,
    there's a lot of horrible rabbit holes you fall into once you try
    to get creative.[^creative]

[^creative]:
    The Flake schema is not, as it might appear, a normal
    attribute set, and also you have to deal with nixpkgs' systems
    (`x86_64-linux` etc.) the moment you step out from the `nixosConfigurations.`
    comfort zone, because you want to put a package you made under `packages`
    and follow the schema, but actually it's `packages.x86_64-linux.hello`,
    because Flakes don't assume your system like that due to pure evaluation,
    and you don't have a list of systems built in to Nix, it's in nixpkgs,
    so you need to get it from `nixpkgs.lib` in some `let ... in` statement
    boilerplate nonsense first if you want to avoid repeating yourself a lot.
    But (to imagine myself a few years ago) as a new Nix user I don't really
    understand functional programming yet, I think, because I've just never
    really tried functional programming before, but there's all these projects
    on GitHub I keep hearing about like `flake-utils-plus` and `flake-parts`
    and all these people coming up with these designs and methods for
    Designing your Flake to be the most ergonomic it can be, and there's these
    functions people keep writing to make `packages` not require repetition,
    and, and, plus, I was reading this blog post about one million nixpkgs
    taking up space on my hard drive and I guess just need to use one `nixpkgs`
    input and it's gonna be a pain to juggle all these nixpkgs versions
    if I want something like `pkgs.unstable.firefox`, and there's the whole
    `inputs.*.follows.*` thing...​ It is a real disaster.

[flakeless-pure-eval]: https://github.com/NixOS/nix/issues/9329
[devenv-eval-cache]: https://devenv.sh/blog/2024/10/03/devenv-13-instant-developer-environments-with-nix-caching/#how-does-it-work

We can get a lot of the good parts of Flakes without the bad parts.

There are still some features that we cannot easily separate from Flakes.
Namely:
pure evaluation,
[which doesn't _necessarily_ need to be tied to Flakes][flakeless-pure-eval];
and evaluation caching, though [projects
like devenv have found tricks to do it without Flakes][devenv-eval-cache].

## What instead?

For dependency pinning, there's tools like [`niv`][niv], [`npins`][npins],
[`lon`][lon] (and probably many others) that do dependency pinning just fine.
I use `npins`,
mostly because it seems like the most widely used alternative to `niv`,
and also because of
[this post by one of Lix's maintainers][pinning-nixos-with-npins]
that makes it look really nice.

Regarding schema, I'm not sure why we don't think of `default.nix` more
creatively (or really, more boringly); why not just imitate Flake
schema, but without all the pain points?

Nothing stops you from structuring `default.nix` like Flake `outputs`,
putting your host's files at `./hosts/ilo`,
and running `nixos-rebuild -f . -A nixosConfigurations.ilo`.

To a past version of myself, I am certain this sounds really opaque; but
now that I feel confident in my understanding of the language, it's
kinda hilarious to me just how much complication Flakes introduced to
the language for me, with its relative ease of use, compared to, well,
trying to grasp the metaphysics of functional programming when I really
have never been much of a programmer in the first place.

Our solution of having `default.nix` just imitate the Flakes schema is
nice for our own uses, and for anyone who might want to use something
from our Nix project.
That said, the real benefit of the schema imposed
by Flakes is that _other people use it too_, so it helps those unfamiliar
to get a feeling for how a Nix project is laid out, if they have the work
of others to refer to.
So it's not really a complete replacement there.
But if you can live with the inconsistency of how modules get
found in your system configurations's `imports` list[^imports-inconsistency]
it's pretty nice.

[^imports-inconsistency]:
    To show a few examples of all the different ways you might import a module:
    there's `self.nixosModules.my-cool-module`,
    `"${agenix}/modules/age.nix"`,
    `"${agenix}/modules/age-home.nix"`,
    `"${nixpkgs}/nixos/modules/profiles/hardened.nix"` (nixpkgs' profiles are
    also accessed like this in Flakes, to be fair),
    `"${home-manager}/nixos"`,
    `"${impermanence}/nixos.nix"`,
    `"${impermanence}/home-manager.nix"`,
    `(imports sources.nixos-cli { inherit pkgs; }).module` (honestly this
    one might be my fault),
    `self.homeManagerModules.my-cool-module`,
    and `"${plasma-manager}/modules"`. That's just what's in my own config.
    I dunno, I guess it just bugs me to see so much variation in how you just
    find the module you're trying to import, compared to Flakes pretty much
    always using some variation on `project.nixosModules.my-module`; that said,
    projects still don't really agree on where to put home-manager modules in
    the Flake schema, for example.

## So how can I do this

It all comes together something like this:

    $ npins init
    [INFO ] Welcome to npins!
    [INFO ] Creating `npins` directory
    [INFO ] Writing default.nix
    [INFO ] Writing initial lock file with nixpkgs entry (need to fetch latest commit first)
    [INFO ] Successfully written initial files to 'npins/sources.json'.
    $ mkdir -p hosts/ilo/ users/somasis/
    $ npins add github --name nixos-unstable --branch nixos-unstable nixos nixpkgs
    [INFO ] Adding 'nixos-unstable' …
        repository: https://github.com/nixos/nixpkgs.git
        branch: nixos-unstable
        submodules: false
        revision: 544961dfcce86422ba200ed9a0b00dd4b1486ec5
        url: https://github.com/nixos/nixpkgs/archive/544961dfcce86422ba200ed9a0b00dd4b1486ec5.tar.gz
        hash: 0k4w73fddkvbcaxshm5mbr6b6k11hm7nz94jxsfmj14bswx2ll0i
        frozen: false
    $ npins add github --name home-manager --branch master nix-community home-manager
    [INFO ] Adding 'home-manager' …
        repository: https://github.com/nix-community/home-manager.git
        branch: master
        submodules: false
        revision: 722792af097dff5790f1a66d271a47759f477755
        url: https://github.com/nix-community/home-manager/archive/722792af097dff5790f1a66d271a47759f477755.tar.gz
        hash: 0h33b93cr2riwd987ii5xl28mac590fm2041c5pcz0kdad3yll4s
        frozen: false
    $ npins add github --branch master nix-community impermanence
    [INFO ] Adding 'impermanence' …
        repository: https://github.com/nix-community/impermanence.git
        branch: master
        submodules: false
        revision: 4b3e914cdf97a5b536a889e939fb2fd2b043a170
        url: https://github.com/nix-community/impermanence/archive/4b3e914cdf97a5b536a889e939fb2fd2b043a170.tar.gz
        hash: 04l16szln2x0ajq2x799krb53ykvc6vm44x86ppy1jg9fr82161c
        frozen: false
    $ vi default.nix ./hosts/ilo/default.nix ./users/somasis/default.nix

Now, we'll set up the main entry-point to the project and its "stuff":

```nix
# default.nix
{
  self ? (import ./. { }),
  sources ? (import ./npins),

  nixpkgs ? sources.nixos,
  ...
}:
let
  nixos =
    nixpkgs: configuration:
    import "${nixpkgs}/nixos/lib/eval-config.nix" {
      modules = [ configuration ];
      specialArgs = {
        inherit nixpkgs self sources;
      };
    };
in
{
  inherit self sources;

  # Setting outPath means that you can do things like
  # "${self}/modules/my-cool-module/thing.nix"
  outPath = ./.;

  nixosConfigurations.ilo = nixos nixpkgs ./hosts/ilo;
  nixosModules.my-cool-module = import ./modules/nixos/my-cool-module;
}
```

```nix
# ./hosts/ilo/default.nix
{
  sources,
  self,
  config,
  pkgs,
  ...
}:
{
  imports = with sources; [
    self.nixosModules.my-cool-module
    "${home-manager}/nixos"
    "${impermanence}/nixos.nix"
  ];

  environment.systemPackages = [
    pkgs.npins
  ];

  users.users.somasis = { };

  home-manager.users.somasis = import "${self}/users/somasis";

  system.stateVersion = "25.05";
}
```

```nix
# ./users/somasis/default.nix
{
  sources,
  config,
  pkgs,
  ...
}:
{
  imports = with sources; [
    "${home-manager}/home-manager.nix"
    "${impermanence}/home-manager.nix"
  ];

  home.stateVersion = "25.05";
}
```

I imagine some reading may have objections to passing `sources` and `self`
to things via `specialArgs`,
but I think this is an exception that makes sense.
We're integrating `npins` into the whole structure of our project[^disambig], in a way that is
basically equivalent to how people use `self` in Flakes land to refer to the
top level of their Flake, and `inputs` to get its input sources.
Usually, one should use `_module.args`;
but since we want to be able to use our `sources` value in `imports`,
we have to pass it through `specialArgs`,
otherwise it'd cause you to run into an infinite recursion
while the NixOS module system tries to get the value of `sources`.

[^disambig]:
    or directory, or repository, whatever you want to call it, whatever it is.

[no-specialArgs]: https://github.com/NixOS/nixpkgs/blob/32397eb652bd302011080df0a4531165a907637c/nixos/default.nix#L1-L4

As to why not use `import "${nixpkgs}/nixos"`, following the channels-utilizing
convention of `import <nixpkgs/nixos>`? Well, that was what I thought would look
nicer as well, but [that interface doesn't allow for setting `specialArgs`, for
some reason][no-specialArgs]; the only arguments it accepts are `configuration`
and `modules`.
There's [a pull request](https://github.com/NixOS/nixpkgs/pull/442886) open to
add `specialArgs` to its function arguments, it turns out.

If you want to use this workflow for your system, you might also want to check
out [this little module][npins-module] I wrote that ensures usage of `npins`
sources in `NIX_PATH`[^/etc/npins] and in the system's Flakes registry,
disabling channels as well.
If you have something like that in your configuration, everything else works
great: `nix run nixpkgs#firefox` works fine,
`nix-shell '<nixpkgs>' -p firefox --run firefox` too.
Like with Flakes, you can explore what's going on in your project using
`nix repl -f .`.

It's very nice and it feels much simpler in terms of project structure.

Feel free to dig around in my [configuration][puter] for more.

[^/etc/npins]:
    Using a layer of indirection in `/etc/npins/<source>` which points
    to `sources.<source>`.

---

Update (2025-10-22):

- [Discussed on NixOS Discourse](https://discourse.nixos.org/t/organizing-your-nix-configuration-without-flakes/71009/3).
- [Discussed on Lobste.rs](https://lobste.rs/s/ikcg1l/organizing_your_nix_configuration).
- Changed remark about `import <nixpkgs/nixos>` not accepting `specialArgs`
  to include a pull request brought to my attention on NixOS Discourse.
- Added a remark about why we use `specialArgs` instead of the more common
  `_module.args`.
- Added a remark about the features that we cannot yet easily do without Flakes,
  in particular pure evaluation and evaluation caching.

Thanks everyone for all your feedback on this post!
