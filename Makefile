# Makefile for xv6 with sysinfo syscall
# This is a PARTIAL Makefile showing only the modifications needed
# Copy this content to the appropriate sections of the original xv6 Makefile

# In the UPROGS section, add:
# $U/_sysinfo\

# Example of complete UPROGS section:
UPROGS=\
	$U/_cat\
	$U/_echo\
	$U/_forktest\
	$U/_grep\
	$U/_init\
	$U/_kill\
	$U/_ln\
	$U/_ls\
	$U/_mkdir\
	$U/_rm\
	$U/_sh\
	$U/_stressfs\
	$U/_usertests\
	$U/_grind\
	$U/_wc\
	$U/_zombie\
	$U/_sysinfo\

# No other changes to Makefile are needed
# The build system will automatically:
# - Compile user/sysinfo.c
# - Link it with the kernel
# - Generate usys.S from usys.pl
