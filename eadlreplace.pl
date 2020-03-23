#!/usr/bin/perl
#use strict;
#use warnings;

# Replace auger and radiative relative intensities in
# existing EADL format file using files
# augertrans.eadl and trans.eadl

print "Name of input reference file in EADL format?  ";
chomp($infile = <>);

print "Name of output file?  ";
chomp($outfile = <>);
$outfile = ">".$outfile;


open(INPUTFILE1, $infile);
$j=0;
while(<INPUTFILE1>){
    my($line) = $_;
    chomp($line);
    $linecontent10[$j] = $line;
    #printf("$linecontent10[$j]\n");
    #if($linecontent1[$j] =~ /92932 91/){
    #	printf("$linecontent1[$j]\n");
    #}
    $j++;
}    
close(INPUTFILE1);

$jmax = $j;

open(INPUTFILE2, 'augertrans.eadl');
$ini_aug=0;
while(<INPUTFILE2>){
    my($line) = $_;
    chomp($line);
    $linecontent2[$ii] = $line;
    $length = length($linecontent2[$ii]);
    if($length < 12){
	if($ini_aug > 0){
	    $maxtrans_aug[$ini_aug] = $ii;
	}
	$ini_aug++;
	$inivac_aug[$ini_aug] = $linecontent2[$ii];
	$ii=1;
    }else{
    $trans_aug[$ini_aug][$ii] = $linecontent2[$ii];
    #printf("$trans_aug[$ini_aug][$ii]\n");    
    $ii++;
    }
}
$maxtrans_aug[$ini_aug] = $ii;
$maxini_aug = $ini_aug;
close(INPUTFILE2);

open(INPUTFILE3, 'trans.eadl');
$ini_rad=0;
while(<INPUTFILE3>){
    my($line) = $_;
    chomp($line);
    $linecontent2[$ii] = $line;
    $length = length($linecontent2[$ii]);
    if($length < 12){
	if($ini_rad > 0){
	    $maxtrans_rad[$ini_rad] = $ii;
	}
	$ini_rad++;
	$inivac_rad[$ini_rad] = $linecontent2[$ii];
	$ii=1;
    }else{
    $trans_rad[$ini_rad][$ii] = $linecontent2[$ii];
    #printf("$trans_rad[$ini_rad][$ii]\n");    
    $ii++;
    }
}
$maxtrans_rad[$ini_rad] = $ii;
$maxini_rad = $ini_rad;
close(INPUTFILE3);

#for ($i=1; $i<=$maxini; $i++){
#    for ($ii=1; $ii<$maxtrans[$i]; $ii++){
#    printf("$trans[$i][$ii]\n"); 
#    }   
#}

$findflag = 0;
open (FILE, $outfile);
for ($j=0; $j<$jmax; $j++){
    if($findflag == 0){
	print FILE "$linecontent10[$j]\n";
    }else{
	$length = length($linecontent10[$j]);
	#printf("$length $linecontent10[$j]\n");
	if($length == 72){
	    print FILE "$linecontent10[$j]\n";
	    $findflag = 0;
	}
    }
    if($linecontent10[$j] =~ /92931 91/){
	#printf("$linecontent10[$j]\n"); 
	for ($i=1; $i<=$maxini_rad; $i++){
	    #printf("$inivac_rad[$i]\n"); 
	    if($linecontent10[$j] =~ /\Q$inivac_rad[$i]\E/){
		$findflag = 1;
		#printf("$inivac_rad[$i]\n");
		for ($ii=1; $ii<$maxtrans_rad[$i]; $ii++){
		    #printf("$trans_rad[$i][$ii]\n");
		    print FILE "$trans_rad[$i][$ii]\n"; 
		}   
	    }
	}
	#print FILE "$linecontent10[$j]\n";
    }
    if($linecontent10[$j] =~ /92932 91/){
	#printf("$linecontent10[$j]\n"); 
	for ($i=1; $i<=$maxini_aug; $i++){
	    #printf("$inivac_aug[$i]\n"); 
	    if($linecontent10[$j] =~ /\Q$inivac_aug[$i]\E/){
		$findflag = 1;
		#printf("$inivac_aug[$i]\n");
		for ($ii=1; $ii<$maxtrans_aug[$i]; $ii++){
		    #printf("$trans_aug[$i][$ii]\n");
		    print FILE "$trans_aug[$i][$ii]\n"; 
		}   
	    }
	}
	#print FILE "$linecontent10[$j]\n";
    }
}
close(FILE);


for ($i=0; $i<$imax; $i++){
    #printf("$atrans1[$i]  $atrans2[$i]  $atrans3[$i]  $arate[$i]  $aenergy[$i]\n");
    $checktrans = "${atrans2[$i]} ${atrans3[$i]}";
    #printf("$checktrans\n");
    for ($j=0; $j<$jmax; $j++){
	if($linecontent1[$j] =~ /92932 91/ && $linecontent1[$j] =~ /\Q$atrans1[$i]\E/){
	    #printf("$linecontent1[$j]\n");
	    $k = $j+1;
	    $length = length($linecontent1[$k]);
	    #$length = 0;
	    while($length < 72){
		if($linecontent1[$k] =~ /\Q$checktrans\E/){
		    $test = substr($linecontent1[$k], 23, $length);
		    #printf("$length        $linecontent1[$k]   $test\n");
		    #printf("$j    $k    $linecontent1[$k]\n");
		    $linecontent1[$k] =~ s/$test/$arate[$i] $aenergy[$i] replaced/g;
		    #printf("$length        $linecontent1[$k]\n");

		    #printf("$linecontent1[$k]\n");
		    #printf("$i          $atrans2[$i]  $atrans3[$i]  $arate[$i]  $aenergy[$i]\n");
		    #printf("\n");
		}
		$k = $k+1;
		$length = length($linecontent1[$k]);
	    }
	}
    }
}


for ($ii=0; $ii<$iimax; $ii++){
    #printf("$trans1[$ii]  $trans2[$ii]  $rate[$ii]  $energy[$ii]\n");
    for ($j=0; $j<$jmax; $j++){
	if($linecontent1[$j] =~ /92931 91/ && $linecontent1[$j] =~ /\Q$trans1[$ii]\E/){
	    #printf("$linecontent1[$j]\n");
	    $k = $j+1;
	    $length = length($linecontent1[$k]);
	    #$length = 0;
	    while($length < 72){
		if($linecontent1[$k] =~ /\Q$trans2[$ii]\E/){
		    $test = substr($linecontent1[$k], 12, $length);
		    #printf("$length        $linecontent1[$k]   $test\n");
		    $linecontent1[$k] =~ s/$test/$rate[$ii] $energy[$ii] replaced/g;
		    #printf("$length        $linecontent1[$k]\n");
		    #printf("$trans1[$ii]  $trans2[$ii]  $rate[$ii]  $energy[$ii]\n");
		    #printf("\n");
		}
		$k = $k+1;
		$length = length($linecontent1[$k]);
	    }
	}
    }
}

#open (FILE, '>test.eadl');
#for ($j=0; $j<$jmax; $j++){
#    print FILE "$linecontent1[$j]\n";
#}
#close(FILE);
