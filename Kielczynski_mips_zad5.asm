.data
errorInputTxt: .asciiz "\nNiepoprawny wybor\n"
selectSymbolTxt: .asciiz "\nKtóry znak wybierasz 'x' lub 'o': "
wrongSymbolTxt: .asciiz "\nNiepoprawny wybor znaku\n"
selectNrOfRoundsTxt: .asciiz "\nWybierz ilosc rund (1-5): "
userActionTxt: .asciiz "\nPodaj pozycje\n"
numberTableTxt: .asciiz "\n1  2  3\n4  5  6\n7  8  9\n"
roundWinComputerTxt: .asciiz "----------------\nWYGRYWA KOMPUTER\n----------------\n"
roundWinUserTxt: .asciiz "-------------\nWYGRYWA GRACZ\n-------------\n"
roundDrawTxt: .asciiz "-----\nREMIS\n-----\n"
endTxt: .asciiz "\nWynik:"
userTxt: .asciiz "\nGracz: "
computerTxt: .asciiz "\nKomputer: "
drawTxt: .asciiz "\nRemisow: "
userSymbol: .byte '-'
computerSymbol: .byte '-'
gameResult: .word 0 0 0
						#k-kolumna #w-wiersz #p-przekatna
helpingTable: .word 0, 0, 0, 0, 0, 0, 0, 0 	# k1, k2, k3, w1, w2, w3, p1, p2

.macro printString(%value)			#funkcja wypisuj¹ca stringa podanego przy wywo³aniu
	li $v0, 4				#zmiana na wypisanie stringa
	la $a0, %value				#przekazanie wartoœci do przepisania
	syscall 				#wypisanie
.end_macro 

.macro getInt					#funkcja pobjeraj¹ca inta od u¿ytkownika
	li $v0, 5				#ustawienie pobrania inta
    	syscall					#pobranie inta
.end_macro

.macro getChar					#funkcja pobjeraj¹ca char od u¿ytkownika
	li $v0, 12				#ustawienie pobrania char
    	syscall					#pobranie chara
.end_macro

.macro printCharAndSpace			#funkcja wypisujaca char-a od u¿ytkownika pod podany rejestr
	li $v0, 11				#ustawienie wypisania char-a
    	syscall					#pobranie inta
    	li $a0, 32				#
	syscall					#spacja
	li $a0, 32				#
	syscall					#spacja
.end_macro

.macro checkPos(%register,%value)
	add $a0, %register, %value
	lb $t2, %value(%register)
	beq $t2, $t4, addComputerSymbol 	# sprawdzamy pozycje z pod %value do wstawienia
.end_macro

.text
main: 
	jal selectNrOfRounds			# Zapytanie siê o liczbe rund
	move $s0, $v0				# Zapamietanie ilosci rund
	
	jal selectSymbol			# Zapytanie o symbol
	
	move $a0,$s0
	jal play				# Rozgrywka
	
	jal printResult				# Wyniki
	j exit					# Koniec

selectNrOfRounds:
	printString(selectNrOfRoundsTxt)	# Zapytanie o ilosc rund
	getChar					#
	blt $v0, 49, wrongNrOfRounds		# Sprawdzanie czy blad
	bgt $v0, 53, wrongNrOfRounds		#
	subi $v0,$v0,48				#zmiana na inta
	jr $ra					# Powrot do main	
wrongNrOfRounds:
	printString(errorInputTxt)		# wypisanie b³edu
	j selectNrOfRounds			# Ponowne zapytanie o ilosc rund

selectSymbol: 					# Przypisanie znaku
	printString(selectSymbolTxt)
	getChar
	beq $v0, 120, setXUser			# 120 = x w ascii
	beq $v0, 111, setOUser			# 111 = o w ascii
	
	printString(wrongSymbolTxt)		# z³y symbol 
	j selectSymbol				# zapytanie jeszcze raz
	
	setXUser:
		li $t0, 120			# Przypisanie x do gracza a o do komputera
		sb $t0, userSymbol		
		li $t0, 111			
		sb $t0, computerSymbol	
	jr $ra					# Powrot do main
	setOUser:
		li $t0, 111			# Przypisanie o do gracza a x do komputera
		sb $t0, userSymbol		
		li $t0, 120			
		sb $t0, computerSymbol		
	jr $ra					# Powrot do main
	
play:
	subi $sp, $sp, 4			# Kopia $ra
	sw $ra, 0($sp)
	
	move $s0, $a0				# Zapamietanie do $s0 ilosci rund
	li $s1, 0x100101c0  			# Adres poczatku tablicy do gry
	
	round:
	beqz $s0, playEnd			# Jezeli 0 zagrane wszystkie n rund
	addi $s0, $s0, -1
	jal clearTable				# czyszczenie tablicy do gry jak i pomocniczej
	
	turn:					#nowa tura
	jal printTable				# wypisanie tablicy do gry
	printString(numberTableTxt)		# 123 456 789 tablica wyboru
	jal getUserAction			# Pobranie i sprawdzenie pozycji gracza
	
	jal ifWin				# Czy gracz wygral
	move $a0, $v0
	bnez $a0, endRound			# jesli !=0 to gracz wygral koniec rundy
	
	jal getComputerAction			# Wybor komputera
	
	move $a0, $v0				#
	beqz $a0, endRound			# 0=remis
	jal ifWin				# Sprawdzenie czy komputer wygral
	
	move $a0, $v0
	bnez $a0, endRound			# jesli !=0 to komputer wygral
	j turn
	
	playEnd:				#koniec rund
	lw $ra, 0($sp)				# Wczytuje $ra ze stosu
	addi $sp, $sp, 4			#
	jr $ra					# Powrot do miejsca wywolania
	
clearTable:
	li $t7, 45				# 45 = '-'
	li $t6, 0				# iterator
	clearLoop:
	add $t5, $s1, $t6			#
	sb $t7, 0($t5)				# Petla ustawiajaca 9 znakow '-' w tablicy
	addi $t6, $t6, 1			#
	blt $t6, 9, clearLoop			#
	
						# zerowanie pomocniczej tablicy
	li $t6, 0				# iterator
	zeroHelpingTable:
	sw $zero,helpingTable($t6)		#
	addi $t6, $t6, 4			#Petla zerujac tablice helpingTable
	blt $t6, 32, zeroHelpingTable		#
	
	jr $ra					# Powort do miejsca wywolania
	
printTable:
	li $t6, 0				# iterator petli
	li $v0, 11
	li $a0, 10				#
	syscall					# Przeniesienie do nowej linii
	printTableLoop:
	add $t7, $s1, $t6			
	lb $a0, 0($t7)				# 1 znak w wierszu n
	printCharAndSpace
	lb $a0, 1($t7)				#2 znak w wierszu n
	printCharAndSpace
	lb $a0, 2($t7)				#3 znak w wierszu n
	printCharAndSpace
	
	li $a0, 10				#
	syscall					# wypisanie nowej lini
	addi $t6, $t6, 3			#
	blt $t6, 9, printTableLoop		#spawdzeni czy wypisalismy cala tablice
	
	jr $ra					#powrot do miejsca wywolania
	
getUserAction:
	subi $sp, $sp, 4			# Kopia $ra
	sw $ra, 0($sp)				#
	
	getUserActionBack:	
	printString(userActionTxt)
	getChar
	
	move $t7, $v0
	blt $t7, 49, wrongActionError		# Mniejsze od 1 w ascii
	bgt $t7, 57, wrongActionError		# Wieksze od 9 w ascii
	
	subi $t7, $t7, 49			# $t7 = liczba w ascii -49
	add $t6, $s1, $t7			# Adres w pamiêci do wybranej pozycji w $t6
	
	lb $t5, 0($t6)				# wczytanie znaku z miejsca
	bne $t5, 45, wrongActionError		# Jezeli wybor !='-' to nie puste miejsce
	
	lb $t5, userSymbol			# Zapisanie znaku na wybranej pozycji
	sb $t5, 0($t6)				#
	
	li $a0, 1				#Aktualizacja tablicy pomocniczej 
	move $a1, $t7				# 
	jal updateHelpingTable		#
	
	lw $ra, 0($sp)			
	addi $sp, $sp, 4			# Powrot
	jr $ra				
	
wrongActionError:
	printString(errorInputTxt)		#blad pozycji i pobranie jeszcze raz
	j getUserActionBack

updateHelpingTable:				# $a0= (1 gracz) lub (-1 komputer)
	subi $sp, $sp, 4			# $a1= pozycja przedial (0-8)
	sw $ra, 0($sp)				#Kopia $ra
	
					# Sprawdzanie ktora kolumna
	div $t7, $a1, 3				# pozycja % 3 = kolumna
	mfhi $t7				#
	jal addControlPoint			#aktualizacja tablicy pomocniczej
					# ktory wierssz
	div $t7, $a1, 3				# pozycja / 3 = wiersz
	add $t7, $t7, 3				# przesuniecie o 3 kolumny
	jal addControlPoint			#aktualizacja tablicy pomocniczej
	
					# Sprawdzenie czy wybor to przekatna 1
	div $t7, $a1, 4				#
	mfhi $t7				# pozycja % 4 == 0  przekatna 1
	bnez $t7, diagonal2			#jesli nie to sprawdzamy czy 2 
	
	li $t7, 6				# aktuaalizacja przekatnej 1 w tablicy pomocniczej
	jal addControlPoint
					# Sprawdzenie czy wybor to przekatna 1
	diagonal2:
	beq $a1, 2, onDiag2			#
	beq $a1, 4, onDiag2			# jezeli jest 2 4 6 to wybor jest na przekatnej 2
	beq $a1, 6, onDiag2			#
	b endAnalizing
	
	onDiag2:
	li $t7,7				# aktuaalizacja przekatnej 2 w tablicy pomocniczej
	jal addControlPoint
	
	endAnalizing:
	lw $ra, 0($sp)				#
	addi $sp, $sp, 4			# Powrot
	jr $ra					#
	
addControlPoint:
	mul $t7, $t7, 4				# 
	lw $t6, helpingTable($t7)		#Aktualizacja puntków kontrolnych 
	add $t6, $t6, $a0			# zmaina 1 to gracz
	sw $t6, helpingTable($t7)		# zmiana 2 to komuter
	jr $ra
	
ifWin:
	li $t7, 0 				#iterator
	ifWinLoop:
	lw $t6, helpingTable($t7)		# Pobranie z tablicy pomocniczej
	
	abs $t5, $t6				# Wartosc bezwzgledna z wyboru
	beq $t5, 3, win				# 3= to ktos wygral
	
	addi $t7, $t7, 4			# iterator + 4
	blt $t7, 32, ifWinLoop		# petla
	
	li $v0, 0				# 0 = brak wygranego
	jr $ra
	
	win: 
	div $v0, $t6, 3				# 1 wygrywa gracz || -1 wygrywa komputer
	jr $ra					# powrot
	
getComputerAction:
	subi $sp, $sp, 4			# Kopia $ra
	sw $ra, 0($sp)				#
	li $v0, 1				# $v0 == 1 dopoki nie zostanie znaleziony ruch

					# Mozliwa wygrana w tym ruchu
	li $t7, 0 				#iterator	
			
	computerActionLoop:
	lw $t6, helpingTable($t7)		# wczytanie liczby z tablicy pomocniczej
	beq $t6, -2, checkPosAction		# Jezeli -2 to komputer wygrywa
	addi $t7, $t7, 4			# iterator + 4 
	blt $t7, 32, computerActionLoop		# petla
	
					# Mozliwa  zablokowac wygrana gracza po tym ruchu
	li $t7, 0 				#iterator
	
	computerActionLoop2:
	lw $t6, helpingTable($t7)		# wczytanie liczby z tablicy pomocniczej
	beq $t6, 2, checkPosAction		# Jezeli 2 to komuter blokuje gracza
	addi $t7, $t7, 4			# iterator +4 
	blt $t7, 32, computerActionLoop2		# 

						# Sprawdzamy w kolejnosci: naro¿niki œrodek a potem œrodki krawedzi
	li $t4, 45 				# 45 = '-' - wolne pole
	
	checkPos($s1,0)				# sprawdzamy naroznik 
	checkPos($s1,2)				# sprawdzamy naroznik
	checkPos($s1,6)				# sprawdzamy naroznik
	checkPos($s1,8)				# sprawdzamy naroznik
	checkPos($s1,4)				# sprawdzamy srodek
	checkPos($s1,1)				# sprawdzamy srodek krawedzi
	checkPos($s1,3)				# sprawdzamy srodek krawedzi
	checkPos($s1,5)				# sprawdzamy srodek krawedzi
	checkPos($s1,7)				# sprawdzamy srodek krawedzi
					
	li $v0, 0				# Zwracam 0 jako remis brak ruchow
	
	lw $ra, 0($sp)				#
	addi $sp, $sp, 4			# Powrot
	jr $ra					#

checkPosAction:					#albo blokada albo wygrana
	div $t5, $t7, 4
	li $t4, 45				# 45 = '-' - wolne pole
	
	blt $t5, 3, checkPosColumn		#szukamy pozycji 
	blt $t5, 6, checkPosRow			#
	beq $t5, 6, checkPosDiagonal1		#
	beq $t5, 7, checkPosDiagonal2		#
	
	checkPosColumn:				#sprawdzanie kolumn i miejsca wygranej
	add $t3, $s1, $t5
	checkPos($t3,0)		
	checkPos($t3,3)
	checkPos($t3,6)
	
	checkPosRow:				#sprawdzanie wierszow i miejsca wygranej
	sub $t3, $t5, 3				
	mul $t3, $t3, 3
	add $t3, $s1, $t3
	checkPos($t3,0)		
	checkPos($t3,1)
	checkPos($t3,2)
	
	checkPosDiagonal1:			#1 przek¹tna szukanie miejsca wygranej
	checkPos($s1,0)		
	checkPos($s1,4)
	checkPos($s1,8)
	
	checkPosDiagonal2:			#2 przekatna szukanie miejsca wygranej
	checkPos($s1,2)		
	checkPos($s1,4)
	checkPos($s1,6)

addComputerSymbol:
	lb $t7, computerSymbol
	sb $t7, 0($a0) 				#zapis znaku
	
	sub $a1, $a0, $s1			# Wyliczenie pozycji computera (0-8)
	li $a0, -1				# Ruch wykoanal komputer -> $a0=-1
	jal updateHelpingTable
	
	lw $ra, 0($sp)				#
	addi $sp, $sp, 4			#
	jr $ra					# powrot
	
endRound: 					# $a0 = -1 komputer, 0 remis, 1 gracz
	mul $t3, $a0, 4
	add $t3, $t3, 4				# wynik komputer, remisy, gracz	
	lw $t4, gameResult($t3)			#
	add $t4, $t4, 1				# Zwiekszenie odpowiedniej punktacji o 1
	sw $t4, gameResult($t3)			#
	
	move $t4, $a0 
	jal printTable
	
	beq $t4, -1, computerWin		#wypisanie wyniku
	beq $t4, 0, draw		
	beq $t4, 1, userWin		
	
	computerWin:
	printString(roundWinComputerTxt)
	j round
	
	draw:
	printString(roundDrawTxt)
	j round
	
	userWin:
	printString(roundWinUserTxt)
	j round	
	
printResult:
	printString(endTxt)
	printString(userTxt)			#wygrane gracza
	li $v0, 1
	lw $a0, gameResult+8
	syscall
	
	printString(computerTxt)		#wygrane komputera
	li $v0, 1
	lw $a0, gameResult
	syscall
	
	printString(drawTxt)			#remisy
	li $v0, 1
	lw $a0, gameResult+4
	syscall	
	jr $ra
exit: 
	li $v0, 10
	syscall
	