#include <stdio.h>
#include <stdlib.h>
#include <string.h>
extern void display_memory(); // goi ham tu asm
long long  lengthOfFile() // lay chieu dai cua file
{
	FILE *fp;
	fp = fopen("tri.txt", "r"); // mo file tri.txt
	if (fp == NULL)
		return -1;
	fseek (fp, 0, SEEK_END);// dat vi tri la cuoi file, tinh tu dau file
	long long res = ftell(fp);// tinh tu vi tri offset den vi tri hien tai cua fp trong file
	fclose(fp);
	return res;
}

void inputFile (char *str) // dua toan bo ky tu trong file vao mot chuoi
{ 
	FILE * fp;
	fp = fopen("tri.txt", "r");
	int i = 0;
	while (!feof(fp))
	{
		str[i++] = fgetc(fp);// duyet den khi het ky tu trong file
	}
	fclose(fp);
}

void main ()
{
	long long length = lengthOfFile(); // do dai file
	char * str = (char*)malloc((length+1)*sizeof(char)); // cap phat dong cho chuoi ky tu co str quan ly dau chuoi, cong 1 do tinh them '\0'
	char c[17];
	inputFile (str); // nhap toan bo ky tu tu file sang chuoi str
	int count = 0;
	for (int i=0;i<length; i++)
	{
		
		c[count++] = *(str+i);
		if (count == 16) // mot lan lay 16 ky tu vao ham display_memory de lam viec
		{
			c[count] = '\0'; // phai cho ky tu cuoi cung la null moi dung duoc
			display_memory(c, count);
			count = 0; // xet lai count = 0 de tiep tuc chen vao chuoi c
		}
	}
	if (count != 0) // xet truong hop so luong ky tu khong chia het cho 16
		display_memory(c, count);
	return;
}
