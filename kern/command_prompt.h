#ifndef FOS_KERN_MONITOR_H
#define FOS_KERN_MONITOR_H
#ifndef FOS_KERNEL
# error "This is a FOS kernel header; user programs should not #include it"
#endif

#include <inc/types.h>

// Function to activate the kernel command prompt
void run_command_prompt();

// Declaration of functions that implement command prompt commands.
int command_help(int , char **);
int command_kernel_info(int , char **);
int command_calc_space(int number_of_arguments, char **arguments);
int command_run_program(int argc, char **argv);
int command_allocpage(int , char **);
int command_writeusermem(int , char **);
int command_readusermem(int , char **);
int command_meminfo(int , char **);

/*ASSIGNMENT-3*/
uint32 ConnectVirtualToPhysical(char** arguments);
uint32 FindVirtualOfPhysical(char** arguments);
int CountUsedModifiedInTable(char** arguments);
int SetModifiedPagesInRangeToNotUsed(char** arguments);
int CopyPage(char** arguments);

int command_cvp(int , char **);
int command_fv(int , char **);
int command_cum(int , char **);
int command_sm2nu(int , char **);
int command_cp(int , char **);

#endif	// !FOS_KERN_MONITOR_H
