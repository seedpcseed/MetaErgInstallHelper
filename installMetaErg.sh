#!/usr/bin/env bash
# Author: Lukas Jansen; revised Patrick Seed
# Licensed under the Academic Free License version 3.0
set -e


tmhmm="tmhmm-2.0c.Linux.tar.gz"
signalp="signalp-5.0b.Linux.tar.gz"


if (( $# != 1 )); then
    echo "Only one parameter allowed!"
    echo "installMetaErg.sh <installdir>"
    exit 1
fi

targetdir="/"
tmhmm32bit=true
swissknife="https://sourceforge.net/projects/swissknife/files/swissknife/1.78/swissknife_1.78.tar.gz/download"
minpath="https://omics.informatics.indiana.edu/mg/get.php?justdoit=yes&software=minpath1.4.tar.gz"

mkdir -p ~/.cpanm

mamba install perl-archive-extract \
perl-bioperl \
perl-bio-eutilities \
perl-dbd-sqlite \
perl-dbi \
perl-file-copy-recursive \
perl-lwp-protocol-https \
aragorn \
blast \
diamond \
hmmer \
minced \
prodigal \
perl-app-cpanminus \
wget \
python=2.7 \
git \
patch \

tar xzf "$tmhmm" -C "$targetdir"
tar xzf "$signalp" -C "$targetdir"

cpanm "$swissknife" -n

#
# MinPath
#
wget -qO- "$minpath" | tar -xzf - 

export MinPath_CONDA_BACKUP=${MINPATH:-}
export MinPath=$CONDA_PREFIX/MinPath

ln -sr $(echo "MinPath/MinPath?.?.py") "bin/MinPath.py"

shebangfix='1 s,^.*$,#!/usr/bin/env perl,'
unamefix="s/\`uname -m\`/'i386'/"

#
# TMHMM
#
mv tmhmm-?.??/bin/* bin/
mv tmhmm-?.??/lib/* lib/

sed -i "$shebangfix" bin/tmhmm
sed -i "$shebangfix" bin/tmhmmformat.pl

if [ "$tmhmm32bit" = true ] ; then
   sed -i "$unamefix" bin/tmhmm
fi

#
# Signalp
#

mv signalp-?.??/bin/* bin/
mv signalp-?.??/lib/* lib/

#
# Metaerg
#
git clone https://github.com/xiaoli-dong/metaerg.git metaerg

ln -sr metaerg/bin/*.pl bin/

echo 
echo "Finished! You can now just activate the conda env (source activate $targetdir) and run the MetaErg scripts. You probably still have to download or build the database."
echo "Download:"
echo "wget http://ebg.ucalgary.ca/metaerg/db.tar.gz"
echo "(After activation) Build into the metaerg default folder:"
echo "setup_db.pl -o $targetdir/metaerg -v 132 # SILVA version"
