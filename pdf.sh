#!/bin/bash

SOURCE_DIR="content"
FECHA_HOY=$(date +"%Y-%m-%d")
mkdir -p pdf
OUTPUT_FILE="pdf/${FECHA_HOY}_playaderatas_archivo.pdf"

echo "🎨 Generando PDF: Portada (P1), Índice (P2), Contenido (P3+)"

# 1. GENERAR FLUJO DE CONTENIDO MANUAL
(
  echo "\maketitle"       # P1: Portada
  echo "\newpage"
  
  echo "\tableofcontents" # P2: Índice
  echo "\newpage"

  # P3 en adelante: Contenido
  for f in $(ls "$SOURCE_DIR"/*.md | sort -V); do
      TITLE=$(pandoc --template <(echo '$title$') "$f" 2>/dev/null)
      [ -z "$TITLE" ] && TITLE=$(basename "$f" .md)
      ENTRY_DATE=$(pandoc --template <(echo '$date$') "$f" 2>/dev/null)
      
      echo "# $TITLE"
      if [ -n "$ENTRY_DATE" ] && [ "$ENTRY_DATE" != "" ]; then
          echo -e "\n*${ENTRY_DATE}*\n" 
      fi
      
      tr -d '\000' < "$f" | sed '1,/---/d; /---/d'
      echo -e "\n\pagebreak\n" 
  done
) | pandoc -o "$OUTPUT_FILE" \
    --pdf-engine=xelatex \
    -V lang=es \
    -V geometry:margin=1in \
    --syntax-highlighting=none \
    -V title="Playa de ratas" \
    -V author="Objeto Imposible" \
    -V mainfont="Helvetica" \
    -V sansfont="Helvetica" \
    -V fontsize=11pt \
    -V colorlinks=true \
    -V linkcolor=blue \
    -H <(echo '
% Anular comandos automáticos de la plantilla de Pandoc
\let\oldmaketitle\maketitle
\renewcommand{\maketitle}{}
\let\oldtableofcontents\tableofcontents
\renewcommand{\tableofcontents}{}

\usepackage{float}
\usepackage{titling}
\usepackage{etoolbox}

% Configuración estética de la Portada (usando los comandos originales guardados)
\pretitle{\begin{center}\LARGE\bfseries}
\posttitle{\end{center}\vspace{2em}}
\predate{} \date{} \postdate{}

% Restaurar comandos para uso manual en el flujo
\let\maketitle\oldmaketitle
\let\tableofcontents\oldtableofcontents

% Espaciado en el Índice
\preto\tableofcontents{\vspace{3em}}
\appto\tableofcontents{\vspace{3em}}

% SOLUCIÓN DEFINITIVA FIGURAS: Acepta argumentos opcionales y los ignora
\makeatletter
\renewenvironment{figure}[1][]{%
  \def\@captype{figure}%
  \centering
}{\par}
\makeatother')

echo "✅ PDF generado con éxito en: $OUTPUT_FILE"
