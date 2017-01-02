#/bin/bash
# Navega na arvore de diretorios, a partir de um ponto inicial, abrir todos os zip's que encontrar pela frente

#/server/ftproot/public/Tiwa/LosGatos_CH4_CO2

first=/server/ftproot/public/Tiwa/LosGatos_N2O_CO
if [[ "x$first" == "x" || ! -d $first ]]; then
    first="."
fi
cd $first
first=$PWD
echo "Diretorio inicial: $first"

list=`find $first -type d `
echo $list

for dir in $list ; do
    echo "----------------------------"
    echo "Diretorio atual: $dir"
    cd $dir
    files=`/bin/ls *.zip 2> /dev/null`
    if  [ ! "x$files" == "x" ]; then
	for arq in $files ; do
	    unzip -b -n $arq
	done
    fi   
done
# muda as permissoes
chown -R vsftpd:vsftpd /server/ftproot/public/Tiwa
chown -R vsftpd:vsftpd /server/ftproot/public/ZF2
#