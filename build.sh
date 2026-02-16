#!/bin/bash
SOURCE_DIR="content"
OUTPUT_DIR="dist"

# Asegurar directorios (aunque Gulp limpie, Pandoc necesita que existan)
mkdir -p "$OUTPUT_DIR"

# 1. GENERAR CONTENIDO DEL ÍNDICE (Semántica Pura)
INDEX_CONTENT="---
title: playaderatas
---

<ol>"

# Listar archivos y procesarlos
for file in $(ls "$SOURCE_DIR"/*.md | sort -V); do
    [ -e "$file" ] || continue
    filename=$(basename "$file" .md)
    
    # Ignorar archivos de sistema o documentación
    [[ "$filename" =~ [Rr][Ee][Aa][Dd][Mm][Ee]|archivo ]] && continue

    # EXTRAER TÍTULO USANDO PANDOC (Más robusto que grep)
    # Esto lee el campo 'title' del YAML o el primer H1 del documento
    TITLE=$(pandoc --template <(echo '$title$') "$file" 2>/dev/null)
    
    # Si Pandoc no encuentra título, usamos el nombre del archivo limpio
    if [ -z "$TITLE" ] || [ "$TITLE" == "" ]; then
        TITLE=$(echo "$filename" | sed 's/^[0-9]*-//; s/^[0-9]*_//; s/-/ /g')
    fi
    
    INDEX_CONTENT="$INDEX_CONTENT
  <li><a href='${filename}.html'>${TITLE}</a></li>"
done

INDEX_CONTENT="$INDEX_CONTENT
</ol>"

# 2. NAVEGACIÓN (Lógica del último archivo)
LAST_FILE_PATH=$(ls "$SOURCE_DIR"/*.md | grep -vE "archivo.md|[Rr][Ee][Aa][Dd][Mm][Ee].md" | sort -V | tail -n 1)
if [ -n "$LAST_FILE_PATH" ]; then
    LAST_FILENAME=$(basename "$LAST_FILE_PATH" .md)
    LAST_TITLE=$(pandoc --template <(echo '$title$') "$LAST_FILE_PATH" 2>/dev/null)
    [ -z "$LAST_TITLE" ] && LAST_TITLE="$LAST_FILENAME"
    
    NAV_LINKS="<li id='nav-index'><a href='index.html'>index</a></li>"
    NAV_LINKS="$NAV_LINKS<li id='nav-last'><a href='${LAST_FILENAME}.html'>$LAST_TITLE</a></li>"
else
    NAV_LINKS="<li><a href='index.html'>inicio</a></li>"
fi

# 3. COMPILACIÓN PANDOC (Preservando la jerarquía)
CURRENT_DATE=$(date +"%d/%m/%Y")

for file in "$SOURCE_DIR"/*.md; do
    [ -e "$file" ] || continue
    filename=$(basename "$file" .md)
    [[ "$filename" =~ [Rr][Ee][Aa][Dd][Mm][Ee]|archivo ]] && continue

    echo "📄 Procesando semántica de: $filename.md"
    
    # Compilación con metadatos inyectados y limpieza de HTML
    pandoc -s "$file" \
           -f markdown+raw_html+raw_attribute+autolink_bare_uris+header_attributes \
           -t html \
           --template="./layout.html" \
           --toc \
           --toc-depth=2 \
           -V "date=$CURRENT_DATE" \
           -V nav-menu="$NAV_LINKS" \
           -o "$OUTPUT_DIR/$filename.html"
done

# Generar Índice Final
echo -e "$INDEX_CONTENT" | pandoc -s \
           -f markdown+raw_html+raw_attribute \
           --template="./layout-archivo.html" \
           -V nav-menu="$NAV_LINKS" \
           -o "$OUTPUT_DIR/index.html"

echo "🚀 Estructura transhistórica generada en $OUTPUT_DIR"
