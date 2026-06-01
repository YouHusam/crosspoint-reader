#!/bin/bash

set -e

cd "$(dirname "$0")"

READER_FONT_STYLES=("Regular" "Italic" "Bold" "BoldItalic")
NOTOSERIF_FONT_SIZES=(12 14 16 18)
NOTOSANS_FONT_SIZES=(12 14 16 18)

reader_fallback_weight() {
  case "$1" in
    Bold|BoldItalic)
      echo "Bold"
      ;;
    *)
      echo "Regular"
      ;;
  esac
}

for size in ${NOTOSERIF_FONT_SIZES[@]}; do
  for style in ${READER_FONT_STYLES[@]}; do
    font_name="notoserif_${size}_$(echo $style | tr '[:upper:]' '[:lower:]')"
    font_path="../builtinFonts/source/NotoSerif/NotoSerif-${style}.ttf"
    output_path="../builtinFonts/${font_name}.h"
    python fontconvert.py $font_name $size $font_path --2bit --compress --pnum > $output_path
    echo "Generated $output_path"
  done
done

for size in ${NOTOSANS_FONT_SIZES[@]}; do
  for style in ${READER_FONT_STYLES[@]}; do
    font_name="notosans_${size}_$(echo $style | tr '[:upper:]' '[:lower:]')"
    font_path="../builtinFonts/source/NotoSans/NotoSans-${style}.ttf"
    output_path="../builtinFonts/${font_name}.h"
    if [[ "$style" == "Regular" || "$style" == "Bold" ]]; then
      fallback_weight=$(reader_fallback_weight "$style")
      python fontconvert.py $font_name $size $font_path \
        ../builtinFonts/source/NotoSansHebrew/NotoSansHebrew-${fallback_weight}.ttf \
        ../builtinFonts/source/NotoSansArabic/NotoSansArabic-${fallback_weight}.ttf \
        --additional-intervals 0x05D0,0x05EA \
        --additional-intervals 0x0600,0x06FF \
        --additional-intervals 0xFB50,0xFB50 \
        --additional-intervals 0xFE70,0xFEFC \
        --2bit --compress --pnum > $output_path
    else
      python fontconvert.py $font_name $size $font_path --2bit --compress --pnum > $output_path
    fi
    echo "Generated $output_path"
  done
done

UI_FONT_SIZES=(10 12)
UI_FONT_STYLES=("Regular" "Bold")

for size in ${UI_FONT_SIZES[@]}; do
  for style in ${UI_FONT_STYLES[@]}; do
    font_name="ubuntu_${size}_$(echo $style | tr '[:upper:]' '[:lower:]')"
    font_path="../builtinFonts/source/Ubuntu/Ubuntu-${style}.ttf"
    hebrew_path="../builtinFonts/source/NotoSansHebrew/NotoSansHebrew-${style}.ttf"
    arabic_path="../builtinFonts/source/NotoSansArabic/NotoSansArabic-${style}.ttf"
    # Ubuntu lacks the Latin Extended Additional block (U+1EA0-U+1EF9) used for
    # Vietnamese tone marks. Append a Vietnamese-only Ubuntu cut so those glyphs
    # are filled from it while every glyph Ubuntu already has stays unchanged.
    viet_path="../builtinFonts/source/Ubuntu/Ubuntu-Vietnamese-${style}.ttf"
    output_path="../builtinFonts/${font_name}.h"
    python fontconvert.py $font_name $size $font_path $hebrew_path $arabic_path $viet_path \
      --additional-intervals 0x05D0,0x05EA \
      --additional-intervals 0x060C,0x060C \
      --additional-intervals 0x061F,0x061F \
      --additional-intervals 0x0621,0x064A \
      --additional-intervals 0x0660,0x0669 \
      --additional-intervals 0x0671,0x0671 \
      --additional-intervals 0xFB50,0xFB50 \
      --additional-intervals 0xFE70,0xFEFC > $output_path
    echo "Generated $output_path"
  done
done

python fontconvert.py notosans_8_regular 8 \
  ../builtinFonts/source/NotoSans/NotoSans-Regular.ttf \
  ../builtinFonts/source/NotoSansHebrew/NotoSansHebrew-Regular.ttf \
  ../builtinFonts/source/NotoSansArabic/NotoSansArabic-Regular.ttf \
  --additional-intervals 0x05D0,0x05EA \
  --additional-intervals 0x060C,0x060C \
  --additional-intervals 0x061F,0x061F \
  --additional-intervals 0x0621,0x064A \
  --additional-intervals 0x0660,0x0669 \
  --additional-intervals 0x0671,0x0671 \
  --additional-intervals 0xFB50,0xFB50 \
  --additional-intervals 0xFE70,0xFEFC > ../builtinFonts/notosans_8_regular.h
echo "Generated ../builtinFonts/notosans_8_regular.h"

echo ""
echo "Running compression verification..."
python verify_compression.py ../builtinFonts/
