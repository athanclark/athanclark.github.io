// Site-wide behaviour: mobile navigation, theme toggle, copy buttons on code
// blocks, and anchor links on headings. Loaded with `defer`.
(function () {
    'use strict';

    // Mobile navigation: preselect the current page, and navigate on change.
    var mobileNav = document.getElementById('page-select');
    var nav = document.querySelector('nav[aria-label="Site"]');
    if (mobileNav && nav) {
        var currentPage = nav.classList[0];
        Array.prototype.forEach.call(mobileNav.options, function (option) {
            if (option.className === currentPage) {
                option.selected = true;
            }
        });
        mobileNav.addEventListener('change', function (e) {
            window.location.pathname = '/' + e.target.value + '.html';
        });
        var current = nav.querySelector('ul > li.' + currentPage + ' > a');
        if (current) {
            current.setAttribute('aria-current', 'page');
        }
    }

    // Theme toggle: flips between light and dark, remembering the choice.
    var toggle = document.getElementById('theme-toggle');
    if (toggle) {
        var root = document.documentElement;
        var prefersDark = window.matchMedia && window.matchMedia('(prefers-color-scheme: dark)');
        var effectiveTheme = function () {
            var explicit = root.getAttribute('data-theme');
            if (explicit === 'light' || explicit === 'dark') {
                return explicit;
            }
            return prefersDark && prefersDark.matches ? 'dark' : 'light';
        };
        var label = function () {
            var next = effectiveTheme() === 'dark' ? 'light' : 'dark';
            toggle.setAttribute('aria-label', 'Switch to ' + next + ' mode');
            toggle.setAttribute('title', 'Switch to ' + next + ' mode');
        };
        label();
        toggle.addEventListener('click', function () {
            var next = effectiveTheme() === 'dark' ? 'light' : 'dark';
            root.setAttribute('data-theme', next);
            try {
                localStorage.setItem('theme', next);
            } catch (e) {
                // Storage may be unavailable (private mode); the toggle still works for this page.
            }
            label();
        });
    }

    var article = document.getElementById('content');
    if (!article) {
        return;
    }

    // Copy buttons on code blocks.
    if (navigator.clipboard) {
        article.querySelectorAll('pre > code').forEach(function (code) {
            var pre = code.parentElement;
            var wrapper = pre.parentElement && pre.parentElement.classList.contains('sourceCode')
                ? pre.parentElement
                : pre;
            wrapper.classList.add('has-copy');
            var button = document.createElement('button');
            button.type = 'button';
            button.className = 'copy-code secondary outline';
            button.textContent = 'Copy';
            button.setAttribute('aria-label', 'Copy code to clipboard');
            button.addEventListener('click', function () {
                navigator.clipboard.writeText(code.innerText).then(function () {
                    button.textContent = 'Copied!';
                }, function () {
                    button.textContent = 'Failed';
                });
                setTimeout(function () { button.textContent = 'Copy'; }, 2000);
            });
            wrapper.appendChild(button);
        });
    }

    // Anchor links on headings that have ids (pandoc generates them).
    article.querySelectorAll('h2[id], h3[id], h4[id]').forEach(function (heading) {
        var anchor = document.createElement('a');
        anchor.className = 'heading-anchor';
        anchor.href = '#' + heading.id;
        anchor.setAttribute('aria-label', 'Link to this section');
        anchor.textContent = '#';
        heading.appendChild(anchor);
    });
})();
