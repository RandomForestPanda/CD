#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "quad_generation.h"

void quad_code_gen(char* a, char* b, char* op, char* c)
{
    if (strcmp(op, "label") == 0)
        fprintf(icg_quad_file, "Label, %s, %s, %s\n",b,c,a);
    else if (strcmp(op, "if") == 0)
        fprintf(icg_quad_file, "if, %s, %s, %s\n", b,c, a);
    else if (strcmp(op, "goto") == 0)
        fprintf(icg_quad_file, "goto, %s, %s, %s\n",b,c,a);
    else
        fprintf(icg_quad_file, "%s , %s , %s , %s\n", op, b, c, a);
}

char* new_temp()  // Returns a pointer to a new temporary
{
    char* temp = (char*)malloc(sizeof(char) * 4);
    sprintf(temp, "t%d", temp_no);
    ++temp_no;
    return temp;
}