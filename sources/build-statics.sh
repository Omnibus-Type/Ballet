#!/bin/sh
set -e
source ../env/bin/activate

echo ".
MAKE UFO
."
rm -rf *.ufo
glyphs2ufo Ballet.glyphs --generate-GDEF
rm Ballet.designspace

##########################################

OTF_DIR=../fonts/otf
TTF_DIR=../fonts/ttf
WEB_DIR=../fonts/web

echo ".
GENERATING STATICS
."
rm -rf $OTF_DIR $TTF_DIR
mkdir -p $OTF_DIR $TTF_DIR

fontmake -m Ballet-static.designspace -i -o ttf --output-dir $TTF_DIR
fontmake -m Ballet-static.designspace -i -o otf --output-dir $OTF_DIR

##########################################

echo ".
POST-PROCESSING TTF
."
ttfs=$(ls $TTF_DIR/*.ttf)
for fonts in $ttfs
do
	gftools fix-dsig -f $fonts
	ttfautohint $fonts $fonts.fix
	[ -f $fonts.fix ] && mv $fonts.fix $fonts
	gftools fix-hinting $fonts
	[ -f $fonts.fix ] && mv $fonts.fix $fonts
done

##########################################

echo ".
POST-PROCESSING 0TF
."
otfs=$(ls $OTF_DIR/*.otf)
for fonts in $otfs
do
	gftools fix-dsig --autofix $fonts
	gftools fix-weightclass $fonts
	[ -f $fonts.fix ] && mv $fonts.fix $fonts
done

##########################################

echo ".
MAKE WEBFONTS
."
rm -rf $WEB_DIR
mkdir -p $WEB_DIR

ttfs=$(ls $TTF_DIR/*.ttf)
for fonts in $ttfs
do
  woff2_compress $fonts
  sfnt2woff-zopfli $fonts
done

woffs=$(ls $TTF_DIR/*.woff*)
for fonts in $woffs
do
	mv $fonts $WEB_DIR
done

##########################################

rm -rf instance_ufo/ *ufo

echo ".
COMPLETE!
."
