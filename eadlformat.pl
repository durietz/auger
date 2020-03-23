#!/usr/bin/perl
#use strict;
#use warnings;


open(INPUTFILE1, 'augertrans.dat');
$i=0;
while(<INPUTFILE1>){
    my($line) = $_;
    chomp($line);
    $linecontent1[$i] = $line;
    $linecontent1[$i] =~ s/E//g;
    $linecontent1[$i] =~ s/\+0/\+ /g;
    $linecontent1[$i] =~ s/\-0/\- /g;
    
    printf("$linecontent1[$i]\n");
    $i++;
}    
close(INPUTFILE1);

$imax = $i;

open(INPUTFILE1, 'augertrans_tot.dat');
$ii=0;
while(<INPUTFILE1>){
    my($line) = $_;
    chomp($line);
    $linecontent11[$ii] = $line;
    $linecontent11[$ii] =~ s/E//g;
    $linecontent11[$ii] =~ s/\+0/\+ /g;
    $linecontent11[$ii] =~ s/\-0/\- /g;
    
    printf("$linecontent11[$i]\n");
    $ii++;
}    
close(INPUTFILE1);

$iimax = $ii;

open(INPUTFILE1, 'trans.dat');
$j=0;
while(<INPUTFILE1>){
    my($line) = $_;
    chomp($line);
    $linecontent2[$j] = $line;
    $linecontent2[$j] =~ s/E//g;
    $linecontent2[$j] =~ s/\+0/\+ /g;
    $linecontent2[$j] =~ s/\-0/\- /g;
    
    printf("$linecontent2[$j]\n");
    $j++;
}    
close(INPUTFILE1);

$jmax = $j;

open(INPUTFILE1, 'trans_tot.dat');
$jj=0;
while(<INPUTFILE1>){
    my($line) = $_;
    chomp($line);
    $linecontent22[$jj] = $line;
    $linecontent22[$jj] =~ s/E//g;
    $linecontent22[$jj] =~ s/\+0/\+ /g;
    $linecontent22[$jj] =~ s/\-0/\- /g;
    
    printf("$linecontent22[$jj]\n");
    $jj++;
}    
close(INPUTFILE1);

$jjmax = $jj;

open(FILE, '>augertrans.eadl');
for($i=0;$i<$imax;$i++){
    print FILE "$linecontent1[$i]\n";
}

close(FILE);

open(FILE, '>augertrans_tot.eadl');
for($ii=0;$ii<$iimax;$ii++){
    print FILE "$linecontent11[$ii]\n";
}

close(FILE);

open(FILE, '>trans.eadl');
for($j=0;$j<$jmax;$j++){
    print FILE "$linecontent2[$j]\n";
}
    
close(FILE);

open(FILE, '>trans_tot.eadl');
for($jj=0;$jj<$jjmax;$jj++){
    print FILE "$linecontent22[$jj]\n";
}
    
close(FILE);

