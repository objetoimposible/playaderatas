#!/bin/bash

SOURCE_DIR="content"
OUTPUT_FILE="dist/playaderatas_archivo.pdf"

echo "🎨 Iniciando generación de PDF transhistórico (Versión Estable)..."

# Crear una corriente de contenido limpio y ordenado
for f in $(ls "$SOURCE_DIR"/*.md | sort -V); do
    # 1. Extraer el título del YAML para usarlo como encabezado de sección
    TITLE=$(pandoc --template <(echo '$title$') "$f" 2>/dev/null)
    [ -z "$TITLE" ] && TITLE=$(basename "$f" .md)
    
    # 2. Enviar al flujo: Título + Contenido (limpiando caracteres nulos y quitando el YAML original)
    echo "# $TITLE"
    tr -d '\000' < "$f" | sed '1,/---/d; /---/d'
    echo -e "\n\pagebreak\n" # Forzar salto de página entre entradas
done | pandoc -o "$OUTPUT_FILE" \
    --pdf-engine=xelatex \
    -V lang=es \
    -V geometry:margin=1in \
    --toc \
    --toc-depth=2 \
    -V title="Playa de ratas" \
    -V author="Objeto Imposible" \
    -V mainfont="Helvetica" \
    -V sansfont="Helvetica" \
    -V fontsize=11pt \
    -V colorlinks=true \
    -V linkcolor=blue \
    -H <(echo '
\usepackage{float}
\usepackage{titling}
\usepackage{etoolbox}

% Estilo de título
\pretitle{\begin{center}\LARGE\bfseries}
\posttitle{\end{center}\vspace{2em}}

% Aire en el índice
\preto\tableofcontents{\vspace{3em}}
\appto\tableofcontents{\vspace{3em}}

% CORRECCIÓN DEFINITIVA DE FIGURAS:
% Acepta los argumentos de Pandoc [htbp] o [H] pero los ignora para evitar errores
\makeatletter
\renewenvironment{figure}[1][]{%
  \def\@captype{figure}%
  \centering
}{\par}
\makeatother')

echo "✅ PDF generado con éxito en: $OUTPUT_FILE"
