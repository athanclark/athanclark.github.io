---
title: OpenChronology
title-suffix: Portfolio
date: 2026-10-05 -- present
keywords: [TypeScript, React, Next.js, Node.js, PostgreSQL, SQLite, Rust, Tauri]
website: https://timescale.info
abstract-title: Summary
abstract:
  OpenChronology is a free, open-source timeline editor for exact dates at any scale, from deep
  time to fractions of a second, with sources on every event. It runs on the web at
  timescale.info, as a desktop app, as a single offline HTML file, or on your own server.
---

<img alt="OpenChronology Logo" src="https://github.com/openchronology/timeline-app/raw/main/logo/logo.svg" class="figure center" />

## Purpose

OpenChronology lets you place anything from the Big Bang to a single millisecond on the same
timeline, and zoom between them without losing precision. Every moment and duration can carry
notes, links, tags and relationships, so a timeline shows its sources, and saved history keeps
earlier versions.

Timelines can be shared publicly or privately, forked, and changed through pull requests, and up
to eight can be compared side by side. They can also be large and live: up to 200,000 events per
timeline by default, with logs streamed in from syslog, journald or an HTTP API.

## Design

Times are stored as arbitrary-precision fractions rather than rounded floating-point numbers, which
is what lets a single timeline span deep time and sub-second events exactly.

The editor is a TypeScript and React application, served by a Next.js and Node.js platform backed
by PostgreSQL. The same editor ships as a Tauri desktop app for Windows, macOS and Linux, and as a
single offline HTML file. Timelines move freely between these editions as `.ochx` (JSON) or `.och`
(SQLite) files, and no account is needed to edit locally.

It is licensed under the GPLv3, and the source is on
[GitHub](https://github.com/openchronology/timeline-app).
