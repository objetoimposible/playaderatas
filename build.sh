#!/bin/bash
SOURCE_DIR="content"
OUTPUT_DIR="dist"
mkdir -p "$OUTPUT_DIR"

# 1. DEFINIR NAVEGACIÓN PRIMERO (Para que esté disponible en todos los pasos)
LAST_FILE_PATH=$(ls "$SOURCE_DIR"/*.md | grep -vE "archivo.md|[Rr][Ee][Aa][Dd][Mm][Ee].md" | sort -V | tail -n 1)
LAST_FILENAME=$(basename "$LAST_FILE_PATH" .md)
LAST_TITLE=$(pandoc --template <(echo '$title$') "$LAST_FILE_PATH" 2>/dev/null)
[ -z "$LAST_TITLE" ] && LAST_TITLE="$LAST_FILENAME"

NAV_LINKS="<li id='nav-index'><a href='index.html'>index</a></li>"
NAV_LINKS="$NAV_LINKS<li id='nav-last'><a href='${LAST_FILENAME}.html'>$LAST_TITLE</a></li>"

# 2. PRE-PROCESAMIENTO: Mapear etiquetas a archivos
declare -A TAG_MAP
ALL_FILES=$(ls "$SOURCE_DIR"/*.md | sort -V)

for file in $ALL_FILES; do
    filename=$(basename "$file" .md)
    [[ "$filename" =~ [Rr][Ee][Aa][Dd][Mm][Ee]|archivo ]] && continue
    
    TAGS_RAW=$(pandoc --template <(echo '$tags$') "$file" 2>/dev/null | tr ',' '\n')
    
    for tag in $TAGS_RAW; do
        clean_tag=$(echo "$tag" | xargs | tr '[:upper:]' '[:lower:]')
        if [ -n "$clean_tag" ]; then
            TAG_MAP["$clean_tag"]+="${file} "
        fi
    done
done

# 3. GENERAR PÁGINAS DE ETIQUETAS INDIVIDUALES (Ahora con NAV_LINKS)
for tag in "${!TAG_MAP[@]}"; do
    TAG_FILENAME="tag-${tag// /-}.html"
    TAG_PAGE_CONTENT="---
title: \"Etiqueta: $tag\"
---
<h3>Entradas sobre <b>$tag</b></h3>
<ul>"
    
    for file_path in ${TAG_MAP[$tag]}; do
        fname=$(basename "$file_path" .md)
        title=$(pandoc --template <(echo '$title$') "$file_path" 2>/dev/null)
        [ -z "$title" ] && title="$fname"
        TAG_PAGE_CONTENT="$TAG_PAGE_CONTENT
  <li><a href='${fname}.html'>${title}</a></li>"
    done
    TAG_PAGE_CONTENT="$TAG_PAGE_CONTENT
</ul>"

    echo -e "$TAG_PAGE_CONTENT" | pandoc -s \
           -f markdown+raw_html \
           --template="./layout-archivo.html" \
           -V lang="es" \
           -V nav-menu="$NAV_LINKS" \
           -o "$OUTPUT_DIR/$TAG_FILENAME"
done

# 4. GENERAR CONTENIDO DEL ÍNDICE PRINCIPAL
INDEX_CONTENT="---
title: playaderatas
---
<ol>"

for file in $ALL_FILES; do
    filename=$(basename "$file" .md)
    [[ "$filename" =~ [Rr][Ee][Aa][Dd][Mm][Ee]|archivo ]] && continue

    TITLE=$(pandoc --template <(echo '$title$') "$file" 2>/dev/null)
    [ -z "$TITLE" ] && TITLE=$(echo "$filename" | sed 's/-/ /g')
    
    TAGS_RAW=$(pandoc --template <(echo '$tags$') "$file" 2>/dev/null | tr ',' ' ')
    TAG_LINKS=""
    for tag in $TAGS_RAW; do
        clean_tag=$(echo "$tag" | xargs | tr '[:upper:]' '[:lower:]')
        if [ -n "$clean_tag" ]; then
            TAG_LINKS="$TAG_LINKS <a href='tag-${clean_tag// /-}.html' class='tag-label'>$clean_tag</a>"
        fi
    done
    
    INDEX_CONTENT="$INDEX_CONTENT
  <li><a href='${filename}.html'>${TITLE}</a> $TAG_LINKS</li>"
done
INDEX_CONTENT="$INDEX_CONTENT
</ol>"

# 5. COMPILACIÓN DE ENTRADAS Y ARCHIVO FINAL
for file in $ALL_FILES; do
    filename=$(basename "$file" .md)
    [[ "$filename" =~ [Rr][Ee][Aa][Dd][Mm][Ee]|archivo ]] && continue
    pandoc -s "$file" -f markdown+raw_html -t html --template="./layout.html" -V lang="es" -V nav-menu="$NAV_LINKS" -o "$OUTPUT_DIR/$filename.html"
done

echo -e "$INDEX_CONTENT" | pandoc -s -f markdown+raw_html --template="./layout-archivo.html" -V lang="es" -V nav-menu="$NAV_LINKS" -o "$OUTPUT_DIR/index.html"

echo "🚀 Estructura completa con etiquetas y menú generada."
