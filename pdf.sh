#!/bin/bash

SOURCE_DIR="content"
FECHA_HOY=$(date +"%Y-%m-%d")
mkdir -p pdf
OUTPUT_FILE="pdf/${FECHA_HOY}_playaderatas_archivo.pdf"
TEMP_MD="pdf/temp_pdf_build.md"
PROJECT_ROOT=$(pwd)

echo "🎨 Generando PDF (Efecto Halftone B/N y Diseño Izquierda)..."

# 1. CREAR ARCHIVO TEMPORAL
cat <<EOF > "$TEMP_MD"
---
title: "Playa de Ratas"
author: "Objeto Imposible"
lang: es
---

\let\oldmaketitle\maketitle
\renewcommand{\maketitle}{}

\thispagestyle{empty}
\oldmaketitle
\clearpage
\pagenumbering{arabic}
\setcounter{page}{2}

\newpage
\tableofcontents
\newpage

EOF

for f in $(ls "$SOURCE_DIR"/*.md | sort -V); do
    TITLE=$(grep -m 1 "^title:" "$f" | sed -E 's/^title:[[:space:]]*//; s/^["'\'']//; s/["'\'']$//')
    [ -z "$TITLE" ] && TITLE=$(basename "$f" .md)
    ENTRY_DATE=$(grep -m 1 "^date:" "$f" | sed -E 's/^date:[[:space:]]*//; s/^["'\'']//; s/["'\'']$//')
    
    echo "📖 Procesando: $TITLE"
    echo '' >> "$TEMP_MD"
    echo '\newpage' >> "$TEMP_MD"
    echo "# $TITLE" >> "$TEMP_MD"
    [ -n "$ENTRY_DATE" ] && echo -e "\n*${ENTRY_DATE}*\n" >> "$TEMP_MD"
    
    awk 'BEGIN {yaml=0; count=0} NR==1 && /^---$/ {yaml=1; count=1; next} yaml==1 && /^---$/ {yaml=0; count=2; next} yaml==0 {print}' "$f" >> "$TEMP_MD"
done

sed -E -i '' 's/!\[([^]]*)\]\(https?:\/\/[^)]+\)/[ **Imagen remota omitida** ]/g' "$TEMP_MD"

# 2. EJECUTAR PANDOC
echo "⚙️  Compilando PDF final..."
pandoc "$TEMP_MD" -o "$OUTPUT_FILE" \
    --pdf-engine=xelatex \
    --resource-path=".:$PROJECT_ROOT:$PROJECT_ROOT/$SOURCE_DIR:$PROJECT_ROOT/img:$PROJECT_ROOT/dist/img" \
    -V geometry:"margin=1in,right=3.5cm" \
    -V mainfont="Helvetica" \
    -V fontsize=10pt \
    -V colorlinks=true \
    -V linkcolor=blue \
    -H <(echo '
\usepackage{float}
\usepackage{titling}
\usepackage{fancyhdr}
\usepackage{tikz}
\usetikzlibrary{patterns}
\usepackage{eso-pic}
\usepackage{graphicx}
\usepackage{xcolor}
\usepackage{caption}

% Definir azul #0000ff
\definecolor{blue}{HTML}{0000FF}

% NÚMEROS LATERALES
\fancyhf{}
\renewcommand{\headrulewidth}{0pt}
\pagestyle{fancy}
\AddToShipoutPictureFG{
  \ifnum\value{page}>1
    \begin{tikzpicture}[remember picture, overlay]
      \node [anchor=center, xshift=-1.2cm] at (current page.east) {\small\thepage};
    \end{tikzpicture}
  \fi
}

% AJUSTE GLOBAL DE IMÁGENES: 100% ancho
\makeatletter
\def\maxwidth{\linewidth}
\def\maxheight{0.45\textheight}
\makeatother
\setkeys{Gin}{width=\maxwidth,height=\maxheight,keepaspectratio}

% --- EFECTO HALFTONE B/N ROBUSTO ---
\usepackage{etoolbox}
\let\oldincludegraphics\includegraphics
\renewcommand{\includegraphics}[2][]{%
  \begin{tikzpicture}[inner sep=0pt, baseline=(img.south)]
    % Forzamos modo de color gris envolviendo el nodo en un grupo de color
    \node (img) {\color{gray}\oldincludegraphics[#1]{#2}};
    \begin{scope}[x={(img.south east)},y={(img.north west)}]
      % Trama de puntos (halftone) más marcada y visible
      \fill [pattern=dots, pattern color=black!70, opacity=0.45] (0,0) rectangle (1,1);
      % Capa de rejilla para acentuar el efecto mecánico
      \fill [pattern=grid, pattern color=black!40, opacity=0.15] (0,0) rectangle (1,1);
    \end{scope}
  \end{tikzpicture}%
}

% ALINEACIÓN IZQUIERDA: Definición segura para evitar "Missing number"
\captionsetup[figure]{justification=raggedright,singlelinecheck=false,font=small,skip=10pt}

\makeatletter
% Capturamos el argumento opcional [#1] para que Pandoc no rompa el motor
\renewenvironment{figure}[1][]{%
  \begin{flushleft}
  \def\@captype{figure}
}{%
  \end{flushleft}
}
\makeatother

\let\oldmaketitle\maketitle
\renewcommand{\maketitle}{}
\let\oldtableofcontents\tableofcontents
\renewcommand{\tableofcontents}{}
\let\maketitle\oldmaketitle
\let\tableofcontents\oldtableofcontents
')

# 3. LIMPIEZA
rm "$TEMP_MD"

if [ -f "$OUTPUT_FILE" ]; then
    echo "------------------------------------------------"
    echo "✅ PDF generado con éxito en: $OUTPUT_FILE"
    echo "🏁 Estética: Imágenes B/N con Trama Halftone (Puntos y Rejilla)."
    echo "🔵 Links: Azules | ⬅️ Alineación: Izquierda."
else
    echo "❌ Error en la generación del PDF."
fi
