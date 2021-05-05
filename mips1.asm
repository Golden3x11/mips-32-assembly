.data		#pocz¹tek sekcji danych
askAboutEquation: .asciiz "\n 1. a=b*(c-d) \n 2. a=b/(c+d) \n 3. a=b*c-d \n Numer wyrazenia, ktorego wartosc nalezy obliczyc:"
a: .asciiz "\n a="
b: .asciiz "\n b="
c: .asciiz "\n c="
d: .asciiz "\n d="
askExit: .asciiz "\n Czy kontynuowaæ? [0]-nie [1]-tak"
divZeroError: .asciiz "\n Nie mozna dzielic przez 0"
actionError: .asciiz "\n Bledny wybor opcji"

.macro print_string(%value)			#funkcja wypisuj¹ca stringa podenego przy wywo³aniu
	li $v0, 4				#zmiana na wypisanie stringa
	la $a0, %value				#przekazanie wartoœci do przepisania
	syscall 				#wypisanie
.end_macro 

.macro get_input(%register)			#funkcja pobjeraj¹ca inta od u¿ytkownika pod podany rejestr
	li $v0, 5				#ustawienie pobrania inta
    	syscall					#pobranie inta
    	move %register, $v0			#przesuniêcie inta na podany wczeœniej rejestr
.end_macro
	
.text
getEquation:
	print_string(askAboutEquation)		#wypisanie równañ
	get_input($t0)				#wczytanie które równanie
	beq $t0, 1,eq1				#przeskok do wybranego równania
	beq $t0, 2,eq2				#przeskok do wybranego równania
	beq $t0, 3,eq3				#przeskok do wybranego równania
	j actionNotGiven			#przeskok do nieporawnej opcji
actionNotGiven:
	print_string(actionError)		#wypisanie b³êdu
	j end					#przeskok do pytania o ponowne liczenie
getVariables:
	print_string(b)				#wypisanie b=
	get_input($t1)				#wczytanie b
	print_string(c)				#wypisanie c=
	get_input($t2)				#wczytanie c
	print_string(d)				#wypisanie d-
	get_input($t3)				#wczytanie d
	
	jr $ra					#powrot do rejestru $ra czyli kolejnej instrukcji po wywo³aniu getVariables
	
eq1:						# równanie 1 a=b*(c-d)
	jal getVariables			#wczytanie b c d  i kolejnej instrukcji do rejestru $ra
	sub $t2,$t2,$t3				#$t2=c-d
	mul $t1,$t1,$t2				#$t1=b*$t2
	j result				#przeskok do wypisania wyniku
	
eq2:						# równanie 2 a=b/(c+d)
	jal getVariables			#wczytanie b c d  i kolejnej instrukcji do rejestru $ra
	add $t2,$t2,$t3				#$t2=c+d
	beq $t2,0,divZero			#b³¹d dzielenia przez 0
	div $t1,$t1,$t2				#$t1=b/$t2
	j result				#przeskok do wypisania wyniku
	
eq3:						# równanie 3 a=b*c-d
	jal getVariables			#wczytanie b c d  i kolejnej instrukcji do rejestru $ra
	mul $t2,$t1,$t2				#$t2=b*c
	sub $t1,$t2,$t3				#$t1=$t2-d
	j result				#przeskok do wypisania wyniku
	
divZero:
	print_string(divZeroError)		#wypisanie b³êdu dzielenia
	j end					#przeskok do zapytania czy kontynuowaæ
	
result:
	print_string(a)				#wypisanie a=
	move $a0,$t1				#przesuniêcie wyniku do rejstru $a0
	li $v0, 1				#ustawinie na wypisanie inta
	syscall 				#wypisanie inta z $a0
	j end					#przeskok do zapytania czy kontynuowaæ
end:
	print_string(askExit)			#zapytnaie siê o skoñczenie programu
	get_input($t0)				#pobranie inta od u¿ytkownika
	beq $t0,1,getEquation			#je¿eli 1 jeszcze raz wykonujemy zadanie
	beq $t0,0,exit				#je¿eli 0 koñczymy
	j actionNotGiven			#niepoprawna opcja
	
exit:						#koniec
