 .data
mycipher: .string ""
sostK: .word 64
blocKey: .string ""
plaintexterror: .string "Error: plaintext string is empty"
blockerror: .string "Error: block encoding string is empty"
inputerror: .string "Error: input string is empty"
myplaintext: .string ""
queue: .string ""
.text
#main function 
la a0 myplaintext 
lb a1 0(a0)
beq a1 zero plaintextempty
#addnewline - adds newline character at end of string
add a2 a0 zero
nlLoop:  #parses string to be encoded until end, then adds newline character
addi a0 a0 1
lb t0 0(a0)
bne t0 zero nlLoop
li t1 10
sb t1 0(a0)
add a0 a2 zero
li a7 4
ecall   #outputs string to be encoded
la s1 mycipher
lb t0 0(s1)
beq t0 zero inputempty
idLoopEncode:  #parses input string, then calls appropriate encoding functions
lb s4 0(s1)
li s3 65
beq s4 zero idLoopDecode  #when end of string isreached, go to decoding
bne s4 s3 notA  #checks if current input string character is A
jal caesarE
addi s1 s1 1
lb s4 0(s1)
notA: 
addi s3 s3 1
bne s4 s3 notB #checks if current input string character is B
jal blockE
addi s1 s1 1
lb s4 0(s1)
notB:
addi s3 s3 1
bne s4 s3 notC #checks if current input string character is C
jal occurrencesE
addi s1 s1 1
lb s4 0(s1)
notC:
addi s3 s3 1
bne s4 s3 notD #checks if current input string character is D
jal dictionaryPE
addi s1 s1 1
lb s4 0(s1)
notD:
j idLoopEncode
idLoopDecode: #parses input string in reverse, calls appropriate decoding functions
ecall  #outputs encoded string
la s1 mycipher
scrolloop:
lb t0 0(s1)
beq t0 zero decode
addi s1 s1 1
j scrolloop
decode:
addi s1 s1 -1
lb t0 0(s1)
beq t0 zero result
li t1 65
bne t0 t1 notAA
jal  caesarD
notAA:
addi t1 t1 1
bne t0 t1 notBB
jal blockD
notBB:
addi t1 t1 1
bne t0 t1 notCC
jal occurrencesD
notCC:
addi t1 t1 1
bne t0 t1 notDD
jal dictionaryPE
notDD:
j decode
result:
ecall  #outputs decoded string
addi a7 zero 93
ecall  #terminates program
#caesar's cypher - Encode
caesarE:
lw t3 sostK
add a4 a0 zero
caesarEChara:  #takes string address and key value, modifies alphabetical characters in string
lb t0 0(a0)                         #load character
beq t0 zero endECaesar              #checks character isn't null (RETURN TO CALLER)
slti t1 t0 65                       # lower external alphabetical character boundary
not t1 t1
slti t2 t0 123                      # upper external alphabetical character boundary
and t1 t1 t2                        
beq t1 zero incrementECaesar        #checks if t0 encoding value is within boundary  (REPEAT OUTER)
slti t1 t0 91                       #lower internal alphabetical character boundary
not t1 t1
slti t2 t0 97                       #upper internal alphabetical character boundary
and t1 t1 t2
bne t1 zero incrementECaesar              #check if t0 encoding value is within internal boundary (REPEAT OUTER)
#both bne fail: chara is alphabetic
slti t1 t0 91
beq t1 zero caseELowerCase          #state if character encoding corresponds to lowercase letter
add t0 t0 t3          #add key value
ucELoop: #apply modulo until conditions on output satisfied
slti t1 t0 91
bne t1 zero incrementECaesar
addi t0 t0 -91 #subtract upper uppercase character bound
addi t0 t0 65  #add lower uppercase character bound
j ucELoop
caseELowerCase:
add t0 t0 t3
lcELoop: #apply modulo until conditions on output satisfied
slti t1 t0 123
bne t1 zero incrementECaesar
addi t0 t0 -123  #subtrasct upper lowercase character bound
addi t0 t0 97	 #add lower lowercase character bound
j lcELoop
incrementECaesar: #parses string
sb t0 0(a0)
addi a0 a0 1
j caesarEChara
endECaesar:
add a0 a4 zero
ret
#caesar's cypher - Decode
caesarD:
add a4 a0 zero
lw t3 sostK
caesarDChara: #takes string address and key value, modifies alphabetical characters in string
lb t0 0(a0)					#load character
beq t0 zero endDCaesar        #checks character isn't null (RETURN TO CALLER)
slti t1 t0 65         #lower external alphabetical character boundary
not t1 t1 
slti t2 t0 123        #upper external aphabetical character boundary
and t1 t1 t2          #checks if t0 encoding value is in inside boundary
beq t1 zero incrementDCaesar  #if the charachter is outside of these bounds, goes to next character (REPEAT OUTER)
slti t1 t0 91         # lower internal alphabetical character boundary
not t1 t1             #invert bit: results 1 if character encoding is above boundary, else 0
slti t2 t0 97         #upper internal alphabetical character boundary
and t1 t1 t2          #checks if character encoding is within bounds
bne t1 zero incrementDCaesar  #if it is, goes to next character (REPEAT OUTER)
slti t1 t0 91         #upper uppercase bound
beq t1 zero caseDLowerCase  #if higher, go to lowercase (UPPERCASE/LOWERCASE)
sub t0 t0 t3        #subtract key
ucDLoop:            #uppercase modulo loop
slti t1 t0 65       #checks if t0 is below lower uppercase bound after subtraction
beq t1 zero incrementDCaesar  #if it isn't, move on to next character (REPEAT OUTER)
addi t0 t0 91                  #add upper bound
addi t0 t0 -65                #subtract lower bound: we have computed one step of modulo
j ucDLoop                     # (REPEAT INNER)
caseDLowerCase:       
sub t0 t0 t3            #subtract key
lcDLoop:            #lowercase modulo loop
slti t1 t0 97         #checks if t0 is below lower lowercase bound after subtraction
beq t1 zero incrementDCaesar      #if it is,  move on to next character (REPEAT OUTER)
addi t0 t0 123            #add upper bound
addi t0 t0 -97            #subtract lower bound: we have computed one step of modulo
j lcDLoop                 # (REPEAT INNER)
incrementDCaesar: #modifies data and parses string
sb t0 0(a0)       #save the eventually modified character
addi a0 a0 1      # go to next character in string
j caesarDChara    # (REPEAT OUTER)
endDCaesar:
add a0 a4 zero
ret # (RETURN TO CALLER)
#block cypher
blockE:
la a2 blocKey
lb t0 0(a2)
beq t0 zero blockEmpty
add t2 a2 zero  #copy encoding string starting address for looping over
add a4 a0 zero
blockEChara: #Takes two strings, uses one to modify the other
lb t0 0(a0) # load byte from string to be encode
lb t1 0(a2) #load byte from encoding string
beq t0 zero endEBlock # checks if t0 is null (RETURN TO CALLER)
beq t1 zero loopEKey 
slti t3 t0 32 #checks lower non-control character bound
slti t4 t0 127  #checks upper characters bound
not t3 t3       #invert byte: results 0 when below 127, 1 otherwise
and t3 t3 t4     #checks if any of the conditions is true
beq t3 zero incrementEBlock    #if we're beyond boundaries, we increment the addresses (REPEAT OUTER)
add t0 t0 t1 # add encoding string value
blockModELoop:  #Modulo loop
slti t3 t0 127  #checks if modified byte is within upper boundary
bne t3 zero incrementEBlock   #if it is, increment (REPEAT OUTER)
addi t0 t0 -127 #subtract upper bound
addi t0 t0 32     #one step of modulo
j blockModELoop   # (REPEAT INNER)
incrementEBlock:  #parses through both strings
sb t0 0(a0)       #save the eventually modified string
addi a0 a0 1      #go to next character in string to be encoded
addi a2 a2 1      #go to next character in encoding string
j blockEChara     #  (REPEAT OUTER)
loopEKey:       #allows for encoding string to loop over string to be encoded
add a2 t2 zero    #simply retrieve starting address from memory
j blockEChara     # (REPEAT OUTER)
endEBlock:
add a0 a4 zero
ret    # (RETURN TO CALLER)
blockD:
la a2 blocKey
add t2 a2 zero #Copy encoding string starting address for looping over
add a4 a0 zero
blockDChara:
lb t0 0(a0)   #load byte from string to be decoded
lb t1 0(a2)   #load byte from decoding string
beq t0 zero endDBlock       # checks if t0 is null (RETURN TO CALLER)
beq t1 zero loopDKey        # checks if t1 is null: if it is, we go back to the beginning of the encoding string
slti t3 t0 32               # checks lower non-control character bound
slti t4 t0 127              #checks upper character bound
not t3 t3                   # invert byte: 0 when below 127, 1 otherwise
and t3 t3 t4                 #checks if one of the conditions is true
beq t3 zero incrementDBlock   #if we're beyound boundaries, we increment the addresses (REPEAT OUTER)
sub t0 t0 t1      #subtract encoding string value
blockModDLoop:    #Modulo loop
slti t3 t0 32     #checks if t0 value lower than 32 after subtraction
beq t3 zero incrementDBlock   # if it isn't, increment (REPEAT OUTER)
addi t0 t0 127      #add upper bound
addi t0 t0 -32      #subtract lower bount: we have performed one step of modulo
j blockModDLoop     # (REPEAT INNER)
incrementDBlock: #parses through both strings
sb t0 0(a0)   #saves eventually modified byte
addi a0 a0 1  # go to next character in string to be encoded
addi a2 a2 1  # go to next character in encoding string
j blockDChara # (REPEAT OUTER)
endDBlock:
add a0 a4 zero
ret           # (RETURN TO CALLER)
loopDKey:   #allows for encoding string to loop over string to be encoded
add a2 t2 zero   #simply retrieve starting address from memory
j blockDChara # (REPEAT OUTER)
#occurrences
occurrencesE:
li a3 -1   #read-data placeholder
li a4 45   # "-"
li t2 0    #ext counter
add a1 a0 zero
locationFinderE:  #finds free memory location for storing encoded string, since this encoding is not in-place
lw t1 0(a1)
beq t1 zero occurrencesEOuter
addi a1 a1 4
add a2 a1 zero
j locationFinderE
occurrencesEOuter:  #parses s till end of string
lb t0 0(a0)
slti t4 t0 32   #valid character check
addi t2 t2 1 #outer loop counter
beq t0 zero endOccurrencesE
bne t4 zero occurrencesEIncreaseInv
sb t0 0(a1)  #save character in encoded string
add t1 a0 zero    #copy a0 address
addi a1 a1 1
add t3 t2 zero
occurrencesEInner: 
lb t4 0(t1)   #load from a0 address copy
beq t4 t0 Ematch  #for every character, parse string looking for instances of the same char
addi t3 t3 1 #inner loop counter
beq t4 zero occurrencesEIncrease #end inner loop
addi t1 t1 1
j occurrencesEInner
Ematch: #when we have a match, write "-" and obscure charachter in the string to be encoded with placeholder value -1
sb a4 0(a1)
sb a3 0(t1)
addi a1 a1 1
positionCodECalculator:
add t4 t3 zero #copy inner loop counter
modulor:  #calculates ascii charachters corresponding to placement
add a6 t4 zero
moduloop: #subtracts 10 increasing counter until value in t4<10
slti t6 t4 10
bne t6 zero modulor2
addi t4 t4 -10
addi t5 t5 1
j moduloop
modulor2:
add a5 t5 zero
li a4 0
othermod:
beq t5 zero subMod
addi a4 a4 10
addi t5 t5 -1
j othermod
subMod: #finish calculating characters by adding 48, then push them onto the stack: less significant digits are pushed first
sub t4 a6 a4
slti t6 a6 10
addi t4 t4 48
addi sp sp -1
sb t4 0(sp)
bne t6 zero write
add t4 a5 zero
j modulor
write:  #writes characters to encoded string by popping them from the stack; most significant digits are popped first
li a4 45
lb t4 0(sp)
beq t4 zero occurrencesEInner
addi sp sp 1
sb t4 0(a1)
addi a1 a1 1
j write 
occurrencesEIncrease: #ends inner loop and prepares for next iteration of outer loop
li t6 32
sb t6 0(a1)
addi a0 a0 1
addi a1 a1 1
j occurrencesEOuter
occurrencesEIncreaseInv: #for invalid characters, we continue parsing without writing anything to destination
addi a0 a0 1
j occurrencesEOuter
endOccurrencesE: #puts encoded string starting address in a0 and returns
li t0 10
sb t0 0(a1)
add a0 a2 zero
ret
occurrencesD:
li a5 32 #load space chara
li a6 45 #load "-" chara
add a1 a0 zero
li a4 10
add t3 a1 zero
locationFinderD:  #finds appropriate memory location for decoded string, as the procedure is not in-place
lw t1 0(a1)
beq t1 zero occurrencesDLoop
addi a1 a1 4
j locationFinderD
occurrencesDLoop:
add t3 a1 zero
lb t0 0(a0)
#sb zero 0(a0)
#beq t0 t5 endOccurrencesD
beq t0 zero endOccurrencesD
addi a0 a0 1
beq t0 a5 checkNext
#beq t0 a6 checkNext
occurrencesDInner:
lb t1 0(a0)
checkDone:
la a2 queue    #load queue address. 
addi a0 a0 1   #increase source string pointer
beq t1 a6 occurrencesDInner  #if we get "-", continue parsing substring
beq t1 a5 occurrencesDLoop   # if we get space, start parsing next substring
li t2 -1      #start tens counter at -1
add t5 a2 zero   #copy starting queue address, t5 is back of the queue
li t4 0          #start number translation at 0
positionCodDCalculator:      #here we push ascii numbers into queue
	beq t1 a5 extractorLoop    #when we get to end of number substring, start extracting from queue
	beq t1 a6 extractorLoop
	beq t1 zero endOccurrencesD
	sb t1 0(t5)     #store current byte at back of queue
	addi t2 t2 1    #increase tens counter
	addi t5 t5 1    #increase queue back pointer
	lb t1 0(a0)     #load next byte
	addi a0 a0 1    #increase source string pointer
	j positionCodDCalculator
extractorLoop:  #here we dequeue 
	lb t1 0(a2)   #take byte from front of queue
	addi a2 a2 1  #increase queue front pointer
	#beq t2 zero writeD  #when we reach end of number substring, go to write
	addi t1 t1 -48     #subtract 48 to get pure number
		add t5 t2 zero  #we put current tens counter in t5

multiplier:     #here we multiply by powers of ten
	beq t5 zero accumulate   
	slli t6 t1 1    #multiply by ten
	slli t1 t1 3    
	add t1 t6 t1    
	addi t5 t5 -1   
	j multiplier
accumulate:
	add t4 t4 t1   #accumulate extracted values one by one into number translation
	beq t2 zero writeD
	addi t2 t2 -1
	j extractorLoop
writeD:
	add t4 a1 t4 #add number translation minus one to destination string starting address
	addi t4 t4 -1
	sb t0 0(t4)   #store byte in t0 there
	lb t1 0(a0)
	addi a0 a0 -1
	beq t1 a5 occurrencesDLoop
	j occurrencesDInner
endOccurrencesD:
lb t0 0(t3)
addi t3 t3 1
bne t0 zero endOccurrencesD
sb t5 0(t3)
add a0 a1 zero
ret
checkNext:
lb t1 0(a0)
beq t1 a6 dash
beq t1 a5 space
j occurrencesDLoop
dash:
add t0 t1 zero
j checkDone
space:
addi a0 a0 2
lb t1 0(a0)
j checkDone
#dictionary
dictionaryPE:
add a4 a0 zero
dictionaryE: #takes in a string, modifies the string according to a set of different rules depending on character subsets
lb t0 0(a0) #load character
beq t0 zero dictEEnd

  # we first need to define a larger acceptable character boundary: it goes from 48 to 122, and has two internal boundaries
slti t1 t0 48
not t1 t1
slti t2 t0 123
and t1 t1 t2
beq t1 zero dictEIncrease
#now we need to separate different cases
slti t1 t0 58
bne t1 zero dictENum
slti t1 t0 91
bne t1 zero dictEMai
slti t1 t0 97
bne t1 zero dictEIncrease
li t1 90   #lowercase letters become uppercase opposite
addi t0 t0 -32
addi t0 t0 -65
sub t0 t1 t0
j dictEIncrease
dictENum: #we load the ascii encoding for 9, obtain the ascii number in t0 by subtracting 48, then subtract
li t1 57
addi t0 t0 -48
sub t0 t1 t0
j dictEIncrease
dictEMai:    #Uppercase letters become lowercase opposite
slti t1 t0 65
bne t1 zero dictEIncrease
li t1 122
addi t0 t0 32
addi t0 t0 -97
sub t0 t1 t0
j dictEIncrease
dictEIncrease:   #go on parsing
sb t0 0(a0)
addi a0 a0 1
j dictionaryE
dictEEnd: 
add a0 a4 zero
jr ra
#errors
plaintextempty:
li a7 4
la a0 plaintexterror
ecall
li a7 93
ecall
blockEmpty:
li a7 4
la a0 blockerror
ecall
li a7 93
ecall
inputempty:
li a7 4
la a0 inputerror
ecall
li a7 93
ecall