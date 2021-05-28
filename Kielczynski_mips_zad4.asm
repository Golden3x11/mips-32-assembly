.data
accuracy: .asciiz "\nPodaj dokladnosc przyblizenia "
error: .asciiz "\nBledna wartosc"
askExit: .asciiz "\nCzy kontynuowac? [0]-nie [1]-tak: "
result: .asciiz "\nPi="
doubles: .double 1.0, 2.0, 4.0, 0.0

.macro printString(%value)			#funkcja wypisuj¹ca stringa podanego przy wywo³aniu
	li $v0, 4				#zmiana na wypisanie stringa
	la $a0, %value				#przekazanie wartoœci do przepisania
	syscall 				#wypisanie
.end_macro 
.text
main:
	jal getAccuracy				#pobranie dokladnosci		
	addu $s0,$zero,$v0			#dokladnosc przesunieta $s0
	
	addu $a0,$zero,$s0			#dokladnosc podana do $a0
	jal calculate				#obliczanie i wypisanie wyniku
	
	j ifEnd					#czy koniec
	
getAccuracy:
	printString(accuracy)
	li $v0, 5				# zmiana na pobranie inta
	syscall 				# pobranie
	move $t0, $v0				# przesuniêcie wyniku do rejstru %register
	ble $t0,0,main				#blad dokladnosci
	jr $ra
	
calculate:
	move $t0,$a0				#dokladnosc do $t0
	li $t1,1				#czy dodajemy czy odejmujemy wartosc 0=dodawanie 1=odejmowanie
	addi $sp, $sp, -4			#zebysmy mogli kozystac z podwojnej precyzji
	addi $sp, $sp, -8			#powiekszenie miejsca na stosie
	ldc1 $f4,doubles			#$f4=1.0
	ldc1 $f6,doubles +8			#$f6=2.0
	ldc1 $f8,doubles +24			#$f8=0.0 tu beda ulamki
	sdc1 $f4,0($sp)				#dodanie pierwszego mianownika
	ldc1 $f10,doubles			#$f10=wynik
	sub $t0,$t0,1				#dekrementacja dokladnosci
	
	loop:
		beqz $t0,endLoop		#gdy wypelnimy dokladnosc koniec
		ldc1 $f8,($sp)			#pobieramy mianownik z poprzedniego ulamku i petli
		add.d $f8,$f8,$f6		#powiekszamy do o 2
		sdc1 $f8,0($sp)			#powiekszony mianownik na stosie
		div.d $f8,$f4,$f8		#obliczmy 1/mianownik
		sub $t0,$t0,1			#dekrementacja dokladnosci
		
		beqz $t1,addition		#jezeli $t1=0 dodawanie
		subi $t1,$t1,1			#zmiana na dodawanie w kolejnym kroku
		sub.d $f10,$f10,$f8		#odejmowanie wartosci ulamka od wyniku
		b loop
		
		addition:
		addi $t1,$t1,1			#zmiana na odejmowanie w kolejnym kroku
		add.d $f10,$f10,$f8		#dodawanie wartosci ulamka od wyniku
		b loop
		
	endLoop:
		addi $sp, $sp,12		#zluzowanie stosu
		ldc1 $f4,doubles+16		#$f4=4.0
		mul.d $f10,$f10,$f4		#mno¿ymy wynik *4 i dostajemy pi
		li $v0, 3			
		mov.d $f12, $f10		#wypisanie wyniku
		syscall
		
ifEnd:
	printString(askExit)			#zapytnaie siê o skoñczenie programu
	li $v0, 5				#ustawienie pobrania inta
    	syscall					#pobranie inta
    	move $t0, $v0				#przesuniêcie inta na podany wczeœniej rejestr
	beq $t0,1,main				#je¿eli 1 jeszcze raz wykonujemy zadanie
	beq $t0,0,end				#je¿eli 0 koñczymy
	printString(error)			#wypisanie ze blad wartosci
	j ifEnd					#niepoprawna opcja
end:
	li $v0, 10				#ustawinie na zakoñczenie programu
	syscall 				#zakoñczenie programu
