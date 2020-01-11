int strlen(char *s){
	int len=0;
	while(*s++) len++;
	return len;
}

char *strcpy(char *dst, const char *src){
	char *dst_orig = dst;
	while(*dst++ = *src++);
	return dst_orig;
}

char *strchr(const char *str, int c){
	while(*str)
		if(*str == c)
			return str;
		else
			str++;
	return 0; // we are not ready yet to have NULL or (void *)0 here; for that we need casts
}

int strcmp(const char *str1, const char *str2){
	while(*str1 && *str2){
		if(*str1 == *str2){
			str1++;
			str2++;
		}else{
			return *str1 - *str2;  // strictly not correct value should be [-1,0,1]
		}
	}
	if(!*str1) return  1;
	if(!*str2) return -1;
	return 0;
}
