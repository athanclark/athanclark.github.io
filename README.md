# athanclark.com

A home-brewed static site generator: [pandoc](https://pandoc.org) turns Markdown into HTML
fragments, and [λtext](https://ltext.github.io/) applies them to the page templates.

## Prerequisites

- [ltext](https://github.com/ltext/ltext) 0.2 or newer (the Rust build), e.g. `cargo install ltext`,
  `brew install ltext/tap/ltext`, `nix profile add github:ltext/ltext`, or a binary from its
  [releases](https://github.com/ltext/ltext/releases/latest)
- [pandoc](https://pandoc.org/installing.html) 3.x
- [Node.js](https://nodejs.org) 20 or newer (Sass, minifiers): run `npm ci` once

Optional, for linting and development: `shellcheck`, `linkchecker`, `watchexec`, and
`static-web-server` (`serve.sh` falls back to Python's `http.server`).

`nix-shell` provides everything except ltext.

## Building

```bash
npm ci
./build.sh        # or: npm run build
```

The site is written to `docs/`. Besides the pages it generates:

- `feed.xml`, an Atom feed of the blog
- `sitemap.xml` and `robots.txt`
- `404.html`, served by GitHub Pages for missing pages
- a "Latest Posts" list on the home page, and the post list on the blog page
- content-hashed `main-<hash>.css` and `site-<hash>.js`

## Writing

- Top-level pages live in `pages/*.md`; add each one to `template/top-level-pages.md`
  (or set `nonav: true` in its front matter, like `404.md`).
- Blog posts live in `pages/blog/*.md`, portfolio projects in `pages/portfolio/*.md`.
  A directory with the same name as the post (e.g. `pages/blog/intset/`) is copied alongside it.
- Front matter: `title`, `abstract` (used for listings, the feed, and `<meta name="description">`),
  `date` (`YYYY-MM-DD` for blog posts), `keywords`, `author`, and optional `scripts`.
- Math (`$...$`, `$$...$$`) is rendered as MathML.

## Serve & watch

```bash
./serve.sh        # http://localhost:8080
./watch.sh        # rebuild on changes
```

## Lint

Checks the shell scripts with shellcheck, that `feed.xml` and `sitemap.xml` are well-formed,
and that `docs/` has no broken internal links. Run it after building:

```bash
./lint.sh
```

## Deployment

`.github/workflows/static.yml` builds and lints on every push and pull request, and deploys
`docs/` to GitHub Pages from `master`.
