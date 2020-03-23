#!/usr/bin/perl
#use strict;
#use warnings;



#PRODUCE LATEX TABLE WITH LEVEL INFORMATION
#------------------------------------------
open(INPUTFILE1, 'xreos.out');
open (MYOUTPUTFILE2, '>radtable.tex');
print MYOUTPUTFILE2 "\\documentclass[14pt,english]{article}\n";
print MYOUTPUTFILE2 "\\usepackage{longtable}\n";
print MYOUTPUTFILE2 "\\usepackage[utf8]{inputenc}\n";
print MYOUTPUTFILE2 "\\usepackage[T1]{fontenc}\n";
#print MYOUTPUTFILE2 "\\usepackage[swedish]{babel}\n";
print MYOUTPUTFILE2 "\\usepackage[cm]{fullpage}\n";
print MYOUTPUTFILE2 "\\thispagestyle{empty}\n";
print MYOUTPUTFILE2 "\\setlength{\\parindent}{0mm}\n";
print MYOUTPUTFILE2 "\\setlength{\\parskip}{0mm}\n";
print MYOUTPUTFILE2 "\\begin{document}\n";
print MYOUTPUTFILE2 "\{\\small\n";
print MYOUTPUTFILE2 "\\begin{longtable}{lrrrrr}\n";
print MYOUTPUTFILE2 "\\caption\{Radiative transition rates.....\}\\\\  \n";
print MYOUTPUTFILE2 "\\hline\n";
print MYOUTPUTFILE2 "Transition & Initial state & Final state & Multipole & Energy & Transition rate  \\\\ \n";
print MYOUTPUTFILE2 "\\hline\n";
print MYOUTPUTFILE2 "\\endfirsthead\n";
print MYOUTPUTFILE2 "\\caption\{Continued.\}\\\\  \n";
print MYOUTPUTFILE2 "\\hline\n";
print MYOUTPUTFILE2 "Transition & Initial state & Final state & Multipole & Energy & Transition rate  \\\\ \n";
print MYOUTPUTFILE2 "\\hline\n";
print MYOUTPUTFILE2 "\\endhead\n";
print MYOUTPUTFILE2 "\\hline\n";
print MYOUTPUTFILE2 "\\endfoot\n";

while(<INPUTFILE1>){
    my($line) = $_;
    chomp($line);
    printf MYOUTPUTFILE2 "$line\n";
}

print MYOUTPUTFILE2 "\\hline \n";
print MYOUTPUTFILE2 "\\end{longtable}\n";
print MYOUTPUTFILE2 "\}\n";

print MYOUTPUTFILE2 "\\end{document}\n";
close(MYOUTPUTFILE2);
close(INPUTFILE1);

