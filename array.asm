.data
    array: .space 1056        # Allocate space for a 22x12 array (264 elements, each 4 bytes)
    rows:  .word 22          # Number of rows
    cols:  .word 12          # Number of columns
    ADDR_DSPL:
        .word 0x10008000
        .text
    	.globl main
    
.text
main:
    # Load array address into a register
    la $t0, array
    
    # Load number of rows and columns
    lw $t1, rows        # Number of rows
    lw $t2, cols        # Number of columns
    addi $t7, $t1, -1   # Compute $t1 - 1 for the index of the lower boundary
    addi $t8, $t2, -1   # Compute $t2 - 1 for the index of the right boundary
    
    li $t3, 0           # Counter for rows (moving down in the array)
    
outer_loop:
    bge $t3, $t1, exit_outer_loop   # Exit if all rows have been initialized
    li $t4, 0                       # Counter for columns (moving right in the array)
    
inner_loop:
    bge $t4, $t2, exit_inner_loop   # Exit if all columns have been initialized
    
    # Calculate index: (row * num_columns + column)
    mul $t5, $t3, $t2   # t5 = row * num_columns
    add $t5, $t5, $t4   # t5 = t5 + column
    
    # Store a colour at the array index
    beq $t3, $zero, set_grey        # If first row, set color to grey
    beq $t3, $t7, set_grey          # If last row, set color to grey
    beq $t4, $zero, set_grey        # If first column, set color to grey
    beq $t4, $t8, set_grey          # If last column, set color to grey
    j set_black                     # Otherwise, set color to black

set_grey:
    addi $t6, $zero, 0x808080         # $t6 = grey
    j store_value
set_black:
    addi $t6, $zero, 0x000000         # $t6 = black
    j store_value
    
store_value:
    # Store value in array
    sw $t6, 0($t0)      # Store $t6 at array[index]
    addi $t0, $t0, 4    # Increment array index by 4 bytes
    
    addi $t4, $t4, 1    # Increment column counter
    j inner_loop        # Continue inner loop

exit_inner_loop:
    addi $t3, $t3, 1    # Increment row counter
    j outer_loop        # Continue outer loop

exit_outer_loop:
    # Call printArray function
    jal printArray
    
    # Exit program
    li $v0, 10           # syscall code for exit
    syscall              # exit program






# Function to print all elements of the array to the bitmap display
printArray:
    # Load array address, number of rows, and columns
    la $s0, array           # $s0 = base address for array
    lw $s1, ADDR_DSPL       # $s1 = base address for display
    
    lw $t1, rows   # Load number of rows
    lw $t2, cols   # Load number of columns

    # Initialize row and column counters
    li $t3, 0      # Row counter
    li $t4, 0      # Column counter

print_outer_loop:
    bge $t3, $t1, exit_print_outer_loop  # Exit if all rows have been printed

print_inner_loop:
    bge $t4, $t2, exit_print_inner_loop  # Exit if all columns have been printed

    # Calculate index: (row * num_columns + column)
    mul $t5, $t3, $t2  # $t5 = row * num_columns
    add $t5, $t5, $t4  # $t5 = index

    # Load value from array and print it
    sll $t6, $t5, 2    # $t6 = index * 4 (byte offset)
    add $t6, $s0, $t6  # $t6 = base address + byte offset
    lw $t7, ($t6)      # Load value from array[$t6]
    
    # Print value to bitmap display
    sw $t7, 0($s1)      # Print colour $t7 to bitmap display
    addi $s1, $s1, 4    # Increment bitmap display index by 4
    
    addi $t4, $t4, 1   # Increment column counter
    j print_inner_loop # Continue inner loop

exit_print_inner_loop:
    li $t4, 0          # Reset column counter
    addi $t3, $t3, 1   # Increment row counter
    j print_outer_loop # Continue outer loop

exit_print_outer_loop:
    jr $ra             # Return to caller