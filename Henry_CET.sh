#!/bin/bash

# Skrypt Henry, wersja 1.3. Korzysta z zainstalowanego programu ansiweather 1.18.

######      HENRY v.1.3      ######

# Określenie zmiennej przechowującej adres katalogu na raporty oraz na pliki pomocniczne

raport=$HOME/pogoda/raporty
pomoce=$HOME/pogoda/tmp

# Określenie zmiennych przechowujących czas

dzien=$(date +%m/%d/%Y)
teraz=$(date +%d/%m/%Y%t%R)

# Określenie miejscowości, w których sprawdzana jest pogoda. Muszą pochodzić z jednej strefy czasowej.

miejsca=( Brussels Biberach Berlin Oslo Warszawa )

# Określenie funkcji 1) wywołujących oraz 2) wprowadzających pomiary do raportów, a także 3) plików pomocniczych

poranny_pomiar () {
	echo "" >> $raport/$a
	echo $teraz >> $raport/$a
	ansiweather -l$a -afalse -strue -ptrue -Htrue -dtrue >> $raport/$a 
} 

pomiary () {
	echo $teraz >> $raport/$a
	ansiweather -l$a -afalse -strue -ptrue -Htrue >> $raport/$a
}	

pora () {
	echo "$dzien $(ansiweather -l$a -afalse -Htrue -dtrue -strue | sed 's/Biberach an der Riss/Biberach-an-der-Riss/' | awk '{print $31, $32}')" > $pomoce/$a-swit
	echo "$dzien 11:59:59 AM" > $pomoce/$a-poludnie
	sleep 3 # z jakiegoś powodu bez sleep pomiar dla Biberachu nie udaje się dla zmierzchu; sed wycina niewłaściwe kolumny
	echo "$dzien $(ansiweather -l$a -afalse -Htrue -dtrue -strue | sed 's/Biberach an der Riss/Biberach-an-der-Riss/' | awk '{print $37, $38}')" > $pomoce/$a-zmierzch
	echo "$dzien 11:59:59 PM" > $pomoce/$a-polnoc
}

odliczanie () {
	if test $(( $(date --file=$pomoce/$b +%s) - $(date +%s) )) -lt 61 && test $(( $(date --file=$pomoce/$b +%s) - $(date +%s) )) -ge -0 
then
	case $pomoce/$b in  
		$pomoce/$a-swit)
			poranny_pomiar
			;;
		*)
			pomiary
			;;
	esac
	fi
}

# Pętla sprawdza, czy można poprawnie raportować pogodę

for a in ${miejsca[@]}
do

# Podpętla sprawdzająca, czy pliki pomocnicze mają poprawne dane dotyczące czasu raportu na aktualny dzień

for b in $a-swit $a-poludnie $a-zmierzch $a-polnoc
	do
		if test -z "$(cat $pomoce/$b)";
	then
		pora
	elif test "$(cat $pomoce/$b | awk '{print $1}')" != $dzien;
	then 
		pora
	elif test -z "$(cat $pomoce/$b | awk '{print $2}')";
	then
		pora

# wreszcie pętla sprawdza, czy nastał czas raportu w oparciu o poprawne dane i, jeśli tak, wywołuje funkcje to realizującą.

	else
		odliczanie
	fi
done

done