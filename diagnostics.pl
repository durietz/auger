#!/usr/bin/perl
#use strict;
#use warnings;
$numargs = $#ARGV + 1;
if ($numargs != 1) {
    print "\nUsage: diagnostics.pl outputfile\n";
    exit;
}
$outputfile=$ARGV[0];
open(INPUTFILE1, $outputfile);
$i=0;
while(<INPUTFILE1>){
    my($line) = $_;
    chomp($line);
    if($line =~ /ACHANNEL/){
	printf("$line\n");
    }
    if($line =~ /INITIAL/){
	printf("    $line\n");
    }
    if($line =~ /FINAL/){
	printf("    $line\n");
    }
    if($line =~ /EXISTS/){
	printf("    $line\n");
    }
    if($line =~ /Error/){
	printf("    $line\n");
    }
    if($line =~ /Maximum iter/){
	printf("    $line\n");
    }
    $i++;
}    
close(INPUTFILE1);

$imax = $i;
