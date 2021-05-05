.data		#początek sekcji danych
askAboutEquation: .asciiz "\n 1. a=b*(c-d) \n 2. a=b/(c+d) \n 3. a=b*c-d \n Numer wyrazenia, ktorego wartosc nalezy obliczyc:"
a: .asciiz "\n a="
b: .asciiz "\n b="
c: .asciiz "\n c="
d: .asciiz "\n d="
askExit: .asciiz "\n Czy kontynuować? [0]-nie [1]-tak"
divZeroError: .asciiz "\n Nie mozna dzielic przez 0"
actionError: .asciiz "\n Bledny wybor opcji"

.macro print_string(%value)			#funkcja wypisująca stringa podenego przy wywołaniu
	li $v0, 4				#zmiana na wypisanie stringa
	la $a0, %value				#przekazanie wartości do przepisania
	syscall 				#wypisanie
.end_macro 

.macro get_input(%register)			#funkcja pobjerająca inta od użytkownika pod podany rejestr
	li $v0, 5				#ustawienie pobrania inta
    	syscall					#pobranie inta
    	move %register, $v0			#przesunięcie inta na podany wcześniej rejestr
.end_macro
	
.text
getEquation:
	print_string(askAboutEquation)		#wypisanie równań
	get_input($t0)				#wczytanie które równanie
	beq $t0, 1,eq1				#przeskok do wybranego równania
	beq $t0, 2,eq2				#przeskok do wybranego równania
	beq $t0, 3,eq3				#przeskok do wybranego równania
	j actionNotGiven			#przeskok do nieporawnej opcji
actionNotGiven:
	print_string(actionError)		#wypisanie błędu
	j end					#przeskok do pytania o ponowne liczenie
getVariables:
	print_string(b)				#wypisanie b=
	get_input($t1)				#wczytanie b
	print_string(c)				#wypisanie c=
	get_input($t2)				#wczytanie c
	print_string(d)				#wypisanie d-
	get_input($t3)				#wczytanie d
	
	jr $ra					#powrot do rejestru $ra czyli kolejnej instrukcji po wywołaniu getVariables
	
eq1:						# równanie 1 a=b*(c-d)
	jal getVariables			#wczytanie b c d  i kolejnej instrukcji do rejestru $ra
	sub $t2,$t2,$t3				#$t2=c-d
	mul $t1,$t1,$t2				#$t1=b*$t2
	j result				#przeskok do wypisania wyniku
	
eq2:						# równanie 2 a=b/(c+d)
	jal getVariables			#wczytanie b c d  i kolejnej instrukcji do rejestru $ra
	add $t2,$t2,$t3				#$t2=c+d
	beq $t2,0,divZero			#błąd dzielenia przez 0
	div $t1,$t1,$t2				#$t1=b/$t2
	j result				#przeskok do wypisania wyniku
	
eq3:						# równanie 3 a=b*c-d
	jal getVariables			#wczytanie b c d  i kolejnej instrukcji do rejestru $ra
	mul $t2,$t1,$t2				#$t2=b*c
	sub $t1,$t2,$t3				#$t1=$t2-d
	j result				#przeskok do wypisania wyniku
	
divZero:
	print_string(divZeroError)		#wypisanie błędu dzielenia
	j end					#przeskok do zapytania czy kontynuować
	
result:
	print_string(a)				#wypisanie a=
	move $a0,$t1				#przesunięcie wyniku do rejstru $a0
	li $v0, 1				#ustawinie na wypisanie inta
	syscall 				#wypisanie inta z $a0
	j end					#przeskok do zapytania czy kontynuować
end:
	print_string(askExit)			#zapytnaie się o skończenie programu
	get_input($t0)				#pobranie inta od użytkownika
	beq $t0,1,getEquation			#jeżeli 1 jeszcze raz wykonujemy zadanie
	beq $t0,0,exit				#jeżeli 0 kończymy
	j actionNotGiven			#niepoprawna opcja
	
exit:						#koniec
