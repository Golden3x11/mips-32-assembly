.data:
inputFirstSentence: .asciiz "\nPodaj pierwsze zdanie: "
inputSecondSentence: .asciiz "\nPodaj drugie zdanie: "
outputAnswer: .asciiz "\nWynik ze stosu:"
outputStack: .asciiz "\nIlosc zaalokowanej pamieci: "
outputTheSameChars: .asciiz "\nIlosc jednakowych znakow: "
outputNotTheSameChars: .asciiz "\nIlosc roznych znakow: "
inputError: .asciiz "\nPodane zdania nie sa tej samej dlugosci\n"
askExit: .asciiz "Czy kontynuować? [0]-nie [1]-tak: "
first: .space 51
second: .space 51
answer: .space 51

.macro printString(%value)			#funkcja wypisująca stringa podanego przy wywołaniu
	li $v0, 4				#zmiana na wypisanie stringa
	la $a0, %value				#przekazanie wartości do przepisania
	syscall 				#wypisanie
.end_macro 

.macro printInt(%value)				#funkcja wypisująca inta podanego przy wywołaniu
	move $a0,%value				#przesunięcie wyniku do rejstru %value
	li $v0, 1				#zmiana na wypisanie inta
	syscall 				#wypisanie
.end_macro 

.macro getInputString(%variable)		#funkcja pobjerająca Stringa od użytkownika pod podana zmienna
	la $a0, %variable			# do jakiego miejsca przenosimy wczytana wartosc
	li $a1, 51				# ile znakow pobieramy
	li $v0, 8				# ustawienie na wczytanie tekstu
	syscall					#
.end_macro

.text
main:
	jal getSentences			#wywolanie metody do wczzytania zdan
	
	jal endOfTheSentences			#wywolanie metody do przejscia na koniec zdan i sprawdzenia dlugosci
	
	addu $a0, $zero, $v0			#pod rejestr $a0 przepisujemy referencje na ostatni znak 1 zdania
	addu $a1, $zero, $v1			#podobnie tylko 2 zdania
	jal compareSentences			#porownanie zdan i zapis na stos
	
	addu $s0, $zero, $v0			#ilos takich samych znakow przepisana na $s0
	
	addu $a0,$zero,$v1			#przekazanie do poczatku stosu
	jal readFromStack			#odczyt ze stosu
	
	addu $a0,$zero,$v0			#przekazanie do metody ilosci znakow ile bylo na stosie
	addu $a1,$zero,$s0			#przekazanie do metody $a0 z iloscia takich samych zankow
	jal result				#metoda wypisujaca wynik
	
	j end					#koniec
	
getSentences:
	printString(inputFirstSentence)		#wypisanie instrukcji 
	getInputString(first)			#pobranie pierwszego zdania
	printString(inputSecondSentence)	#wypisanie instrukcji
	getInputString(second)			#pobranie drugiego zdania
	jr $ra					#powrot do miejsca wywolania
	
endOfTheSentences:
	la $t0, first				#iterator po pierwszym zdaniu
	la $t1, second				#iterator po drugim zdaniu
	
	lengthLoop:				#petla badajaca dlugosc
		lb $t6,($t0)			#pobranie do $t6 znaku z pod wartosci $t0 -1 zdanie
		lb $t7,($t1)			#tak jak wyzej tylko dla 2 zdania
		beq $t6,10,endIfFirstEnd10	#jezeli pierwszy wyraz sie skonczy koncem lini
		beq $t7,10,endIfError		#jezeli 2 zdanie sie skonczy przed 1 to wiadomo ze sa roznej dlugosci
		beqz $t6,endIfFirstEnd0		#jezeli pierwszy wyraz sie skonczy 0
		beqz $t7,endIfError		#jezeli 2 zdanie sie skonczy przed 1 to wiadomo ze sa roznej dlugosci
		addi $t0,$t0,1			#inkrementacja iteratora
		addi $t1,$t1,1			#inkrementacja iteratora
		b lengthLoop			#powrot do petli
	
	endIfFirstEnd10:			#przypadek gdy 1 zdanie sie skonczy		
		beq $t7,10,endLengthLoop	#gdy zdanie 2 sie skonczylo przechodzimy do zamiany na stosie
		b endIfError
	endIfFirstEnd0:				#przypadek gdy 1 zdanie sie skonczy		
		beqz $t7,endLengthLoop		#gdy zdanie 2 sie skonczylo przechodzimy do zamiany na stosie
	endIfError:				#gdy zdanie 1 lub 2 jest dluzsze
		printString(inputError)		#wypisanie bledu
		j ifEnd				#przeskok do procedury ifEnd
	endLengthLoop:
		subu $t0, $t0, 1		# Odjecie 1 znaku
		subu $t1, $t1, 1		# Odjecie 1 znaku
		addu $v0, $zero, $t0		# Zwrcanie wskaznika na ostatni normalny znak zdania 1
		addu $v1, $zero, $t1		# -||- zdania 2
	jr $ra					#powrot do miejsca wywolania
	
compareSentences:
	addu $t0, $zero, $a0			# Wczytanie argumentow: wskaznik na ostatni znak zdania 1
	addu $t1, $zero, $a1			#-||- zdania 2
	
	li  $t2,0				#ile takich samych znakow
	add $t3,$zero,$sp			#poztek stosu
	li  $t4,36				# $ w ascii
	compareLoop:
		lb $t6,($t0)			#wczytanie kolejnego znaku
		lb $t7,($t1)			#       -||-
		
		beqz $t6, endCompareLoop	# Jezeli $t6 jest 0 to koniec zdania
		
		sub $t0, $t0, 1			#dekrementacja iteratora
		sub $t1, $t1, 1			#       -||-
	
		
		beq $t6,$t7,equalChar		#jesli znaki sa takie same przeskok do equqalChar
						#jesli rozne
		addi $sp, $sp,-1		#zrobienie miejsca na stosie
		sb $t4, 0($sp)			#zapis znaku $ na stosie
		b compareLoop			#powrot do poczatku petli
		
		equalChar:
		addi $t2,$t2,1			#powiekszenie ilosci tych samych znakow
		addi $sp, $sp,-1		#zrobienie miejsca na stosie
		sb $t6, 0($sp)			#zapis znaku na stosie
		b compareLoop			#powrot do poczatku petli
	endCompareLoop:
		add $v0,$zero,$t2		#przekazanie wartosci po skonczeniu metody -ilosc takich samych znakow	
		add $v1,$zero,$t3		#poczatek stosu
	jr $ra					#powrot do miejsca wywolania
	
readFromStack:
	add $t0,$zero,$a0			#wczytanie poczatku stosu przed wczytaniem
	add $t2,$zero,$sp			#nr stosu ze znakami
	li $t1,0				#iterator bo buforze
	readLoop:
		beq $t0,$sp,endReadLoop		#gdy juz nie ma zapisanych znakow na stosie
		lb $t7,0($sp)			#wczytanie znaku ze stosie
		add $sp,$sp,1			#zwolnienie miejsca na stosie
		sb $t7,answer($t1)		#zapisanie znaku w buforze
		
		add $t1, $t1, 1			# Przesunienie wskaznika buforu
		b readLoop
	endReadLoop:
		sub $t0,$t0,$t2				
		add $v0,$zero,$t0		#przekazanie wartosci po skonczeniu metody -ilosc takich samych znakow	
		sb $zero ,answer($t1)		#dodaniw znaku w ascii 0
		jr $ra				# Powrot do miejsca wywolania
result:
	add $t0,$a0,$zero
	sub $t1,$a0,$a1				#obliczenie ilosci roznych znakow (suma znakow-liczba tych samych)
	printString(outputAnswer)		#
	printString(answer)			#wypisanie wyniku
	printString(outputStack)		#
	printInt($t0)				#wypisanie zaalokowanej pamieci
	printString(outputTheSameChars)		#
	printInt($a1)				#wypisanie ile bylo tych samych znakow
	printString(outputNotTheSameChars)	#
	printInt($t1)				#wypisanie ile bylo roznych znakow
	
	jr $ra					#powrot do miejsca wywolania
ifEnd:
	printString(askExit)			#zapytnaie się o skończenie programu
	li $v0, 5				#ustawienie pobrania inta
    	syscall					#pobranie inta
    	move $t0, $v0				#przesunięcie inta na podany wcześniej rejestr
	beq $t0,1,main				#jeżeli 1 jeszcze raz wykonujemy zadanie
	beq $t0,0,end				#jeżeli 0 kończymy
	j ifEnd					#niepoprawna opcja
end:
	li $v0, 10				#ustawinie na zakończenie programu
	syscall 				#zakończenie programu
