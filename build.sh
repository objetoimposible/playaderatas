#!/bin/bash
SOURCE_DIR="content"
OUTPUT_DIR="dist"

# 1. GENERAR CONTENIDO DEL ÍNDICE
INDEX_CONTENT="---
title: playaderatas
---

::: {=html}
<h1>playaderatas</h1>
<ol>"

for file in $(ls "$SOURCE_DIR"/*.md | sort -V); do
    [ -e "$file" ] || continue
    filename=$(basename "$file" .md)
    if [[ "$filename" != "archivo" ]] && [[ "$filename" != [Rr][Ee][Aa][Dd][Mm][Ee] ]]; then
        TITLE=$(grep -m 1 '^title: ' "$file" | sed 's/title: //; s/"//g; s/'\''//g')
        [ -z "$TITLE" ] && TITLE=$(grep -m 1 '^# ' "$file" | sed 's/# //')
        [ -z "$TITLE" ] && TITLE=$(echo "$filename" | sed 's/^[0-9]*-//; s/^[0-9]*_//')
        
        INDEX_CONTENT="$INDEX_CONTENT
  <li><a href='${filename}.html'>${TITLE}</a></li>"
    fi
done

INDEX_CONTENT="$INDEX_CONTENT
</ol>
:::"

# 2. NAVEGACIÓN
LAST_FILE_PATH=$(ls "$SOURCE_DIR"/*.md | grep -vE "archivo.md|[Rr][Ee][Aa][Dd][Mm][Ee].md" | sort -V | tail -n 1)
LAST_FILENAME=$(basename "$LAST_FILE_PATH" .md)
LAST_TITLE=$(grep -m 1 '^title: ' "$LAST_FILE_PATH" | sed 's/title: //; s/"//g; s/'\''//g')
[ -z "$LAST_TITLE" ] && LAST_TITLE=$(grep -m 1 '^# ' "$LAST_FILE_PATH" | sed 's/# //')
[ -z "$LAST_TITLE" ] && LAST_TITLE=$(echo "$LAST_FILENAME" | sed 's/^[0-9]*-//; s/^[0-9]*_//')

NAV_LINKS="<li><a href='index.html'><b>inicio</b></a></li>"
if [ -n "$LAST_FILENAME" ]; then
    NAV_LINKS="$NAV_LINKS<li><a href='${LAST_FILENAME}.html'>$LAST_TITLE</a></li>"
fi

# 3. COMPILACIÓN PANDOC
CURRENT_DATE=$(date +"%d/%m/%Y")
for file in "$SOURCE_DIR"/*.md; do
    [ -e "$file" ] || continue
    filename=$(basename "$file" .md)
    [[ "$filename" =~ [Rr][Ee][Aa][Dd][Mm][Ee]|archivo ]] && continue
    
    FILE_TITLE=$(grep -m 1 '^title: ' "$file" | sed 's/title: //; s/"//g; s/'\''//g')
    [ -z "$FILE_TITLE" ] && FILE_TITLE=$(grep -m 1 '^# ' "$file" | sed 's/# //')
    [ -z "$FILE_TITLE" ] && FILE_TITLE="$filename"

    echo "📄 Procesando: $filename.html"
    pandoc -s "$file" -f markdown+raw_html+raw_attribute+autolink_bare_uris \
           --template="./layout.html" --metadata title="$FILE_TITLE" \
           -V "date=$CURRENT_DATE" -V nav-menu="$NAV_LINKS" -o "$OUTPUT_DIR/$filename.html"
done

echo -e "$INDEX_CONTENT" | pandoc -s -f markdown+raw_html+raw_attribute+autolink_bare_uris \
           --template="./layout-archivo.html" \
           -V nav-menu="$NAV_LINKS" \
           -o "$OUTPUT_DIR/index.html"

echo "🚀 Contenido generado en $OUTPUT_DIR"
