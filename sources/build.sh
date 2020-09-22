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

echo ".
GENERATING VARIABLE
."
rm -rf ../fonts/variable
mkdir -p ../fonts/variable

VF_PATH=../fonts/variable/Ballet[opsz].ttf
fontmake -m Ballet-variable.designspace -o variable --output-path $VF_PATH

##########################################

echo ".
POST-PROCESSING VF
."
vfs=$(ls $VF_PATH)
for font in $vfs
do
	gftools fix-dsig --autofix $font
	gftools fix-nonhinting $font $font.fix
	mv $font.fix $font
	gftools fix-unwanted-tables --tables MVAR $font
done
rm ../fonts/variable/*gasp*

python gen_stat.py $VF_PATH

##########################################

rm -rf instance_ufo/ *ufo

echo ".
COMPLETE!
."
