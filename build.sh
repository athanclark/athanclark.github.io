#!/usr/bin/env bash
# Static site generator for athanclark.com.
#
# Pipeline, per page:
#   markdown --pandoc--> stage1 body + meta
#            --ltext (wrapper.html)--> stage2 page, still a function of the sitenav & footer
#            --ltext (sitenav, footer)--> docs/
# Then: blog index, home page "latest posts", Atom feed, sitemap, CSS/JS bundles,
# minification and cache-busting.

set -euo pipefail
shopt -s nullglob globstar

readonly SITE_URL="https://athanclark.com"
readonly SITE_TITLE="athanclark.com"
readonly AUTHOR="Athan Clark"
readonly LATEST_POSTS=3
readonly WORDS_PER_MINUTE=230

PANDOC_FLAGS=(--from markdown+grid_tables --mathml)

for tool in pandoc ltext npx sha256sum; do
    if ! command -v "$tool" > /dev/null; then
        echo "error: required tool '$tool' is not installed" >&2
        exit 1
    fi
done

echo "--------------------------------"
echo "  Building $SITE_TITLE"
echo "  (pandoc $(pandoc --version | head -n1 | cut -d' ' -f2), $(ltext --version))"
echo "--------------------------------"

rm -rf build/ docs/
mkdir -p build/{idents,descs,metas,items,feed}
mkdir -p build/stage1/{blog,portfolio} build/stage2/{blog,portfolio}
mkdir -p docs/{blog,portfolio}

# --- helpers -------------------------------------------------------------------

# field TEMPLATE FILE: render a single metadata field of a markdown file as plain text.
field() {
    pandoc -s --template "$1" -t plain --wrap=none "$2"
}

xml_escape() {
    sed -e 's/&/\&amp;/g' -e 's/</\&lt;/g' -e 's/>/\&gt;/g' -e 's/"/\&quot;/g' <<< "$1"
}

# canonical_url PATH: absolute URL for a site path (index.html becomes /).
canonical_url() {
    if [ "$1" = "/index.html" ]; then
        echo "$SITE_URL/"
    else
        echo "$SITE_URL$1"
    fi
}

# reading_time FILE: estimated minutes to read the body (front matter excluded).
reading_time() {
    local words
    words=$(awk 'NR==1 && /^---$/ {fm=1; next} fm && /^(---|\.\.\.)$/ {fm=0; next} !fm' "$1" | wc -w)
    echo $(( (words + WORDS_PER_MINUTE - 1) / WORDS_PER_MINUTE ))
}

# render_meta SRC OUT URLPATH [extra pandoc args...]
render_meta() {
    local src=$1 out=$2 urlpath=$3
    shift 3
    local desc
    desc=$(field template/desc.html "$src")
    pandoc -s --wrap=none --template template/meta.html "$src" \
        -M canonical="$(canonical_url "$urlpath")" \
        -M plaindesc="$desc" \
        "$@" \
        -o "$out"
}

# wrap META IDENT BODY OUT: apply the page wrapper to a page body (stage 2).
wrap() {
    ltext --raw "$1" --raw "$2" --raw "$3" "template/wrapper.html $1 $2 $3" > "$4"
}

# --- blog ------------------------------------------------------------------------

generateblogposts() {
    local src post date plaintitle plaindesc meta url

    for src in pages/blog/*.md; do
        post=$(basename "$src" .md)
        url="/blog/$post.html"
        echo "  blog/$post"
        if [[ -d pages/blog/$post ]]; then
            cp -r "pages/blog/$post" docs/blog/
        fi
        date=$(field template/date.html "$src")
        plaintitle=$(field template/title.html "$src")
        plaindesc=$(field template/desc.html "$src")
        meta=build/metas/blog-$post.html

        pandoc --toc -s --template template/blog-post.html "${PANDOC_FLAGS[@]}" "$src" \
            -M readingtime="$(reading_time "$src")" \
            -o "build/stage1/blog/$post.html"
        render_meta "$src" "$meta" "$url" -M ogtype=article
        echo blog > build/idents/blog
        wrap "$meta" build/idents/blog "build/stage1/blog/$post.html" "build/stage2/blog/$post.html"

        # Listing entry: "date<TAB>html" so the list can be sorted newest-first.
        printf '%s\t%s\n' "$date" \
            "$(pandoc -s --template template/post-item.html -M url="$url" "$src" -t html | tr '\n' ' ')" \
            >> build/items/blog.tsv

        # Atom feed entry.
        cat > "build/feed/$date-$post.xml" <<EOF
  <entry>
    <title>$(xml_escape "$plaintitle")</title>
    <link href="$SITE_URL$url" />
    <id>$SITE_URL$url</id>
    <published>${date}T00:00:00Z</published>
    <updated>${date}T00:00:00Z</updated>
    <summary>$(xml_escape "$plaindesc")</summary>
  </entry>
EOF
    done

    if [ -f build/items/blog.tsv ]; then
        sort -r build/items/blog.tsv | cut -f2- > build/items/blog-sorted.html
    else
        : > build/items/blog-sorted.html
    fi
}

# Append "<h2>heading</h2><ul>items</ul>" to a stage1 page.
append_post_list() {
    local page=$1 heading=$2 items=$3
    {
        echo "<h2>$heading</h2>"
        echo '<ul class="post-list">'
        cat "$items"
        echo '</ul>'
    } >> "build/stage1/$page.html"
}

generatefeed() {
    local updated
    updated=$(sort -r build/items/blog.tsv 2> /dev/null | head -n1 | cut -f1)
    updated=${updated:-$(date -u +%F)}
    {
        cat <<EOF
<?xml version="1.0" encoding="utf-8"?>
<feed xmlns="http://www.w3.org/2005/Atom">
  <title>$SITE_TITLE</title>
  <subtitle>Blog posts by $AUTHOR</subtitle>
  <link href="$SITE_URL/feed.xml" rel="self" />
  <link href="$SITE_URL/blog.html" />
  <id>$SITE_URL/</id>
  <updated>${updated}T00:00:00Z</updated>
  <author><name>$AUTHOR</name></author>
EOF
        for entry in $(printf '%s\n' build/feed/*.xml | sort -r); do
            cat "$entry"
        done
        echo '</feed>'
    } > docs/feed.xml
}

# --- portfolio ---------------------------------------------------------------------

generateportfolioprojects() {
    local src project meta
    echo portfolio > build/idents/portfolio

    for src in pages/portfolio/*.md; do
        project=$(basename "$src" .md)
        echo "  portfolio/$project"
        if [[ -d pages/portfolio/$project ]]; then
            cp -r "pages/portfolio/$project" docs/portfolio/
        fi
        meta=build/metas/portfolio-$project.html

        pandoc -s --template template/portfolio-project.html "${PANDOC_FLAGS[@]}" "$src" \
            -o "build/stage1/portfolio/$project.html"
        render_meta "$src" "$meta" "/portfolio/$project.html"
        wrap "$meta" build/idents/portfolio "build/stage1/portfolio/$project.html" \
            "build/stage2/portfolio/$project.html"
    done
}

# --- top-level pages ---------------------------------------------------------------

generatepages() {
    local src page ident meta

    # Blog posts first, so the blog and home pages can list them.
    generateblogposts
    generateportfolioprojects

    for src in pages/*.md; do
        page=$(basename "$src" .md)
        echo "  $page"
        ident=build/idents/$page
        echo "$page" > "$ident"
        meta=build/metas/$page.html

        if ! grep -Fq "\"/$page.html\"" template/top-level-pages.md \
            && ! grep -q '^nonav: *true' "$src"; then
            echo "warning: pages/$page.md is not linked from template/top-level-pages.md" >&2
        fi

        pandoc "${PANDOC_FLAGS[@]}" "$src" -o "build/stage1/$page.html"
        render_meta "$src" "$meta" "/$page.html"

        case "$page" in
            blog)
                append_post_list blog "Blog Posts" build/items/blog-sorted.html
                ;;
            index)
                head -n "$LATEST_POSTS" build/items/blog-sorted.html > build/items/latest.html
                append_post_list index "Latest Posts" build/items/latest.html
                ;;
        esac

        wrap "$meta" "$ident" "build/stage1/$page.html" "build/stage2/$page.html"
    done
}

# Apply the sitenav & footer to every stage2 page (stage 3 → docs/).
finalizepages() {
    local page out
    pandoc template/top-level-pages.md -o build/sitenav.html
    sed "s/YEAR/$(date +%Y)/" template/footer.html > build/footer.html

    for page in build/stage2/**/*.html; do
        out=docs/${page#build/stage2/}
        ltext --raw build/sitenav.html --raw build/footer.html \
            "$page build/sitenav.html build/footer.html" > "$out"
    done
}

generatesitemap() {
    local page path
    {
        echo '<?xml version="1.0" encoding="UTF-8"?>'
        echo '<urlset xmlns="http://www.sitemaps.org/schemas/sitemap/0.9">'
        for page in docs/**/*.html; do
            path=/${page#docs/}
            [ "$path" = "/404.html" ] && continue
            echo "  <url><loc>$(canonical_url "$path")</loc></url>"
        done
        echo '</urlset>'
    } > docs/sitemap.xml

    cat > docs/robots.txt <<EOF
User-agent: *
Allow: /

Sitemap: $SITE_URL/sitemap.xml
EOF
}

# --- assets --------------------------------------------------------------------------

# Content-hash an asset and point the STYLES / SITEJS placeholders at it.
cachebust() {
    local file=$1 placeholder=$2 hash name
    hash=$(sha256sum "$file" | cut -c1-10)
    name="${file%.*}-$hash.${file##*.}"
    mv "$file" "$name"
    sed -i "s|$placeholder|/${name#docs/}|g" docs/**/*.html
}

buildassets() {
    local js
    npx sass --no-source-map --style=compressed --quiet-deps \
        --silence-deprecation=import --silence-deprecation=global-builtin \
        --silence-deprecation=color-functions --silence-deprecation=if-function --silence-deprecation=slash-div \
        styles/main.scss docs/main.css

    npx terser scripts/site.js --compress --mangle -o docs/site.js
    for js in docs/blog/**/*.js docs/portfolio/**/*.js; do
        npx terser "$js" --module --compress --mangle -o "$js"
    done

    npx html-minifier-terser \
        --input-dir docs --output-dir docs --file-ext html \
        --collapse-whitespace --conservative-collapse \
        --remove-comments \
        --remove-redundant-attributes \
        --remove-script-type-attributes \
        --remove-style-link-type-attributes \
        --minify-css true --minify-js true

    cachebust docs/main.css STYLES
    cachebust docs/site.js SITEJS

    cp -r images docs/images
}

generatepages
finalizepages
generatefeed
generatesitemap
buildassets

echo "Done: $(find docs -type f | wc -l) files in docs/"
