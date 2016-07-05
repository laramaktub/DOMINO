#!/bin/sh
## Obtaining DOMINO files for generation of installer for Linux distribution

## $1 DOMINO git repository
## $2 qt qmake

if [ $# -eq 0 ]
  then
    echo ""
    echo "Please provide two arguments:"
        echo "
        $0 arg1 arg2"
        echo ""
        echo "
        arg1 = DOMINO git repository [full path]
        arg2 = Path for Qt base qmake [Qt static]
        "
        exit
fi

working_dir=`pwd`
DOMINO_installer_folder=$working_dir"/"DOMINO_installer_folder
mkdir $DOMINO_installer_folder

echo ""
echo "+ Changing dir to: DOMINO git repository"
cd $1

echo "+ Copying necessary files"
cp ."/"src"/"DOMINO_perl_code"/"*pl $DOMINO_installer_folder
cp -r ."/"src"/"DOMINO_Qt_code $DOMINO_installer_folder"/"

cp ."/"files"/"db_default.tar.gz $DOMINO_installer_folder
cp ."/"files"/"*Linux.gz $DOMINO_installer_folder
cp ."/"files"/"tarGZ_modules_Perl.tar.gz $DOMINO_installer_folder
cp ."/"files"/"tarGZ_modules_Perl_NGSQCToolkit.tar.gz $DOMINO_installer_folder
cp ."/"files"/"*pl $DOMINO_installer_folder
cp ."/"files"/"*Linux.sh $DOMINO_installer_folder
cp ."/"files"/"uninstaller.sh $DOMINO_installer_folder
cp ."/"files"/"fonts.tar.gz $DOMINO_installer_folder
cp ."/"files"/"Linux_libs.tar.gz $DOMINO_installer_folder

cp ."/"docs"/"LOGO"/"DOMINO_icon-small.png $DOMINO_installer_folder
cp ."/"docs"/"LOGO"/"DOMINO_logo.png $DOMINO_installer_folder
cp ."/"docs"/"LOGO"/"logo.png $DOMINO_installer_folder
cp ."/"docs"/"LOGO"/"domino_pieza.ico $DOMINO_installer_folder
cp ."/"docs"/"TUTORIAL $DOMINO_installer_folder
cp ."/"docs"/"VERSION $DOMINO_installer_folder

cp ."/"Change.log $DOMINO_installer_folder
cp ."/"LICENSE.txt $DOMINO_installer_folder
cp ."/"README $DOMINO_installer_folder
cp ."/"NEWS $DOMINO_installer_folder

mkdir $DOMINO_installer_folder"/"example
cp ."/"example"/"454_reads"/"*fastq $DOMINO_installer_folder"/"example

cd $DOMINO_installer_folder
cd DOMINO_Qt_code
echo ""
echo "+ Generating a Makefile for DOMINO"
$2 DOMINO.pro
make
echo ""
echo ""
echo "+ Removing temporary files"
ls $DOMINO_installer_folder"/DOMINO_Qt_code/"*.o | while read files;
do
	rm $files
done
echo ""
echo ""
echo "Done!!"