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

int signum(const int a){
	return (a > 0) - (a < 0);
}

int strcmp(const char *str1, const char *str2){
	while(*str1 && *str2){
		if(*str1 == *str2){
			str1++;
			str2++;
		}else{
			return signum(*str1 - *str2);
		}
	}
	if(!*str1) return  1;
	if(!*str2) return -1;
	return 0;
}
