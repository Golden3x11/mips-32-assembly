.data						#deklaracja danych
encryptOrDecrypt: .asciiz "\n[S] szyfrowanie, [D] deszyfrowanie:\nJaka operacja: "
askForTextToChange: .asciiz "\nPodaj tekst Zakres 0-50 \n" 
askForKey: .asciiz "Podaj klucz Zakres 0-25: " 
resultText: .asciiz "Wynik:\n"
errorInput: .asciiz "\nNiepoprawna podana wartosc"
option: .space 2				#
word: .space 51					#deklaracja zmiennych
answer: .space 51				#

.macro print_string(%value)			#funkcja wypisująca stringa podanego przy wywołaniu
	li $v0, 4				#zmiana na wypisanie stringa
	la $a0, %value				#przekazanie wartości do przepisania
	syscall 				#wypisanie
.end_macro 

.macro getInputString(%variable,%size)		#funkcja pobjerająca Stringa od użytkownika pod podana zmienna
	la $a0, %variable				# do jakiego miejsca przenosimy wczytana wartosc
	li $a1, %size				# ile znakow pobieramy
	li $v0, 8				# ustawienie na wczytanie tekstu
	syscall					#
.end_macro
.text
getOption:
	print_string(encryptOrDecrypt) 		#wypisanie tekstu
	
	getInputString(option,2)			#wczytanie Stringa
	
	la $t7, option				# przepisanie word do $t1
	lb $t0, ($t7)				# $t0 przechowuje tryb programu
	
	beq $t0, 68,getWord			#poprawne wartosci przechodzimy do wczytania ciagu
	beq $t0, 83,getWord			#
	
	j inputError
	
getWord:
	print_string(askForTextToChange)	#zapytanie o ciag do zmiany
	getInputString(word,51)			#wczytanie ciagu
	
getKey:
	print_string(askForKey)			#zapytanie o klucz
	li $v0, 5				#ustawienie pobrania inta
    	syscall					#pobranie inta
    	
    	bgt $v0,25, inputError			#
	blt $v0, 0, inputError			# Sprawdzenie czy klucz zostal wybrany prawidlowo
	
    	move $t1, $v0				#przesunięcie klucza do $t1
    	
    	la $t2, word				# przepisanie poczatku word-a do $t7
	li $t3,0				# iterator po nowym tekscie
    	
    	beq $t0, 68, decryptLoop		# Przeniesienie do odpowiedniej petli
	beq $t0, 83, encryptLoop		#

decryptNotLetter:	
	addi $t2,$t2,1				#iterator zwiekszony o 1

decryptLoop:					#odszyfrowywanie

	lb $t7, ($t2)				#wczytanie kolejnego znaku
	beqz $t7,result				#jezeli 0 to koniec ciagu
	
	blt $t7, 65, decryptNotLetter		# Jezeli poza A-Z to przeskoczenie petli
	bgt $t7, 90, decryptNotLetter		#
	
	sub $t7,$t7,$t1				#znak-klucz
	bgt $t7, 64, nextD			#jesli poprawna wartosc idziemy do nextD
	addi $t7,$t7,26				#jesli nie zmieniamy na poprawny znak
	
	nextD:
	sb $t7, answer($t3)			#przepisanie znaku o numerze w $t7
	addi $t2, $t2, 1			#iterator zwiekszony o 1
	addi $t3, $t3, 1			#iterator zwiekszony o 1

	j decryptLoop

encryptNotLetter:	
	addi $t2,$t2,1				#iterator zwiekszony o 1	
	
encryptLoop:					#szyfrowanie
	lb $t7, ($t2)				#wczytanie kolejnego znaku
	beqz $t7,result				#jezeli 0 to koniec ciagu
	
	blt $t7, 65, encryptNotLetter		# Jezeli poza A-Z to przeskoczenie petli
	bgt $t7, 90, encryptNotLetter		#
	
	add $t7,$t7,$t1				#klucz +znak
	blt $t7, 91, nextE			#jesli porawna wartosc idziemy do next
	sub $t7,$t7,26				#jesli nie to zmieniamy na poprawny znak
	
	nextE:
	sb $t7, answer($t3)			#przepisanie znaku o numerze w $t7
	addi $t2, $t2, 1			#iterator zwiekszony o 1	
	addi $t3, $t3, 1			#iterator zwiekszony o 1		
	j encryptLoop

inputError:
	print_string(errorInput)
	j getOption

result:			
	print_string(resultText)		#wypisanie wynik
	print_string(answer)			#wypisanie wyniku
	
	li $v0, 10				#ustawinie na zakończenie programu
	syscall 				#zakończenie programu

	
