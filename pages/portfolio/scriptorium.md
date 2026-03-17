---
title: Scriptorium
title-suffix: Portfolio
date: 2025-09-24 -- 2025-09-15
keywords: [Rust, Tauri, React, Mantine, TypeScript]
website: https://github.com/athanclark/scriptorium
abstract-title: Summary
abstract:
  Scriptorium is a note-taking application that optionally connects with external databases for
  synchronizing data. It is built as a Tauri application, making it suitable for use on desktops.
  It was inspired by Joplin and Microsoft OneNote, but I wanted to give it the ability to store
  data on an external database.
---

<img alt="Scriptorium Icon" src="https://github.com/athanclark/scriptorium/raw/master/assets/app-icon.svg" class="figure center" />

## Purpose

Scriptorium is a note-taking application which aims to be distributed with respect to how it conducts back-ups.
Natively, all notes are stored in a local SQLite Database, but you can extend it to use other more robust, network-enabled
databases as well, like PostgreSQL and MySQL.

## Design

The user interface is a React application front-end and uses Tauri to manage operating system integration.
There are other third-party libraries used in it as well, like CodeMirror for the text editor.
