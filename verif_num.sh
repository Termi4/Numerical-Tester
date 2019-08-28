#!/bin/bash
#
# verif_num.sh - Exibi as interações possiveis entre números fornecidos pelo usuário através de uma TUI (Text User Interface)
#
# Autor: Marcos Samuel <m.samuel43.yahoo@gmail.com>
#
# Modo de uso:  Insira qualquer número inteiro no campo de texto e selecione 
# o botão "ADD", após isso você pode "Finalizar" a inserção para que o 
# programa trabelhe com os números fornecidos e exiba o resultado, como a soma 
# e multiplicação entre eles, se o número e par ou ímpar etc
#
# Obs: 
# Se "Finalizar" a inserção sem forcener nenhum valor o programa e encerrado
# Você pode fornecer varios números de uma vez os separando por espaços
#
# Licença: GPL
#
# Variáveis
title="Analisador Númerico"
dir=/tmp/.anum.txt

# Funções
# Janela de erro para debug
function erro {
	dialog --msgbox "$1" 0 0
	exit 1
}

# Verifica se o número inserido e válido ou não
function verify {
	if ! echo "$1" | grep -q -v "[^0-9-]" || [ $(echo $1 | fgrep -o "-" | wc -l) -gt 1 ] || [ "$1" = "-" ]
        then
		return 0
        else
		if echo "$1" | grep -q -
                then
                        if [ "${1:0:1}" = "-" ]
                        then
                                return 1
                        else
                                return 0
                        fi
                else
                      return 1
                fi
        fi
}

# Formata o número inserido. Ex .05 -> 0.5, 00000 -> 0 ou -000001.2 -> -1.2
function formatnumber {
	a=$1
	hifen=1
	
	if [ "$(echo $a | grep -o "[0-9-]" | head -n 1)" = "-" ]
	then
		a=${a:1:${#a}}
		hifen=0
	fi
	
	declare -i i=0
	cont0=$(echo $a | fgrep -o 0 | wc -l)
	while [ $i -lt $cont0 ]
	do
		a=${a##0}
		((i++))
	done
	
	if [ $hifen -eq 0 ] 
	then
		a="-$a"
	fi

	if [ "$a" = "" ] || [ "$a" = "-" ]
	then
		a=0
	fi	

	echo $a
}

# Gera as propriedades de cada números [ Ìmpar/Par | ^2 | sqrt ]
function calc {
        soma=$(bc <<< "scale=$2; $soma + $1")
        mult=$(bc <<< "scale=$2; $mult * $1")
        el2=$(bc <<< "scale=$2; $1 ^2")

        if [ $[ $1 % 2 ] -eq 0 ]
        then
                reip="Par"
        else
                reip="Ìmpar"
        fi

        if [ $1 -lt 0 ]
        then
                echo "[ $reip | $(formatnumber $el2) | --- ]"
        else
                sqrt=$(bc <<< "scale=$2; sqrt($number)")
		echo "[ $reip | $(formatnumber $el2) | $(formatnumber $sqrt) ]" 
        fi
}

# Encerra o programa e limpa a tela
function sair {
	clear
	exit 0
}

# Palco
while : 
do	
	num[$count]=$(dialog --stdout --backtitle "$title" --title "Números" --ok-label "ADD" --cancel-label "Finalizar" --inputbox "${num[*]}\n\nDigite o $(echo $[ $count + 1 ])º número: " 0 0) # Janela inicial para inserção dos números
	
	# Tomada de desição do botão "Finalizar"
	case $? in
		1)
			if [ ${#num[*]} -lt 2 ]
			then
				sair
			fi

			break
		;;
		255)
			sair
		;;
	esac
	
	# Separa os números por espaço, verifica e aloca-os no array
	for number in $(echo ${num[$count]} | tr ' ' '\n')
	do
		if verify $number 
		then
			num[$count]=""
			continue
		else
			num[$count]=$(formatnumber $number)
			((count++))	
		fi
	done
done

# Cria e inseri textos no arquivo_resultado
echo "Posº: Num [ Ìmpar/Par | ^2 | sqrt ]" > $dir
echo >> $dir

# Ordena os números
declare -i count=0 scale=2 soma=0 mult=1
for number in $(echo ${num[*]} | tr ' ' '\n' | sort -b -n)
do
	soma=$(bc <<< "scale=$scale; $soma + $number")
       	mult=$(bc <<< "scale=$scale; $mult * $number")

	((count++))
  	echo "$countº: $number $(calc $number $scale)" >> $dir
done

if [ ${#num[*]} -gt 2 ]
then
	echo >> $dir
	echo Soma: $soma >> $dir
	echo Multiplicação: $mult >> $dir
fi

# Apresenta o resultado final e encerrar
dialog --backtitle "$title" --title "Resultado" --textbox "$dir" 0 0
sair
