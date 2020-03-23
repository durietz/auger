#!/Usr/bin/perl

print 'Enter minimum electron energy: ';
$aEmin = <STDIN>; chomp $aEmin;
print 'Enter maximum electron energy: ';
$aEmax = <STDIN>; chomp $aEmax;
print 'Enter minimum x-ray energy: ';
$xEmin = <STDIN>; chomp $xEmin;
print 'Enter maximum x-ray energy: ';
$xEmax = <STDIN>; chomp $xEmax;
    
# AUGER

open $fh1, '<', "augertrans.out" or die $!;
$i = 0;
while (<$fh1>) {
    (@ch1[$i], @ch2[$i], @ch3[$i], @sw[$i], @energy[$i], @rate[$i], @inlev[$i]) = split;
    $ach1max = @ch1[$i] if (@ch1[$i]>$ach1max);
    $ach2max = @ch2[$i] if (@ch2[$i]>$ach2max);
    $ach3max = @ch3[$i] if (@ch3[$i]>$ach3max);
    $inlevmax = @inlev[$i] if (@inlev[$i]>$inlevmax);
    #print "@ch1[$i] @ch2[$i] @ch3[$i] @sw[$i] @energy[$i] @rate[$i] @inlev[$i]\n";
    if (@energy[$i] > $aEmin and @energy[$i] < $aEmax){
	$arate[@ch1[$i]][@ch2[$i]][@ch3[$i]][@inlev[$i]] += @rate[$i];
	$aenergy[@ch1[$i]][@ch2[$i]][@ch3[$i]][@inlev[$i]] += @rate[$i]*@energy[$i];
	$asw[@ch1[$i]][@ch2[$i]][@ch3[$i]][@inlev[$i]] = @sw[$i];
	$i++;
    }
}
$imax = $i - 1;
close $fh1;

for($ch1=0;$ch1<=$ach1max;$ch1++){
    for($ch2=0;$ch2<=$ach2max;$ch2++){
	for($ch3=0;$ch3<=$ach3max;$ch3++){
	    $aswsum = 0;
	    for($inlev=0;$inlev<=$inlevmax;$inlev++){
		if( $arate[$ch1][$ch2][$ch3][$inlev]){
		    $aratew[$ch1][$ch2][$ch3] += $arate[$ch1][$ch2][$ch3][$inlev] * $asw[$ch1][$ch2][$ch3][$inlev];
		    $aenergyw[$ch1][$ch2][$ch3] += $aenergy[$ch1][$ch2][$ch3][$inlev] * $asw[$ch1][$ch2][$ch3][$inlev] / $arate[$ch1][$ch2][$ch3][$inlev];
		    $aswsum += $asw[$ch1][$ch2][$ch3][$inlev];
		    #print "$ch1 \t $ch2 \t $ch3 \t $inlev\t $rate[$ch1][$ch2][$ch3][$inlev] \t $asw[$ch1][$ch2][$ch3][$inlev] \n";
		}
	    }
	    if($aswsum){
		$aratew[$ch1][$ch2][$ch3] = $aratew[$ch1][$ch2][$ch3] / $aswsum;
		$aratewsum[$ch1] += $aratew[$ch1][$ch2][$ch3];
		$aenergyw[$ch1][$ch2][$ch3] = $aenergyw[$ch1][$ch2][$ch3] / ($aswsum*1000000);
		#print "$ch1 \t $ch2 \t $ch3 \t $aratew[$ch1][$ch2][$ch3]  \t $aenergyw[$ch1][$ch2][$ch3] \n";
	    }
	}
    }
}

# X-RAY

open $fh1, '<', "trans.out" or die $!;
$i = 0;
$inlevmax = 0;
while (<$fh1>) {
    ~s/D/E/g;
    (@ch1[$i], @ch2[$i], @sw[$i], @energy[$i], @rate[$i], @inlev[$i]) = split;
    $xch1max = @ch1[$i] if (@ch1[$i]>$xch1max);
    $xch2max = @ch2[$i] if (@ch2[$i]>$xch2max);
    $inlevmax = @inlev[$i] if (@inlev[$i]>$inlevmax);
    #print "@ch1[$i] @ch2[$i] @ch3[$i] @sw[$i] @energy[$i] @rate[$i] @inlev[$i]\n";
    if (@energy[$i] > $xEmin and @energy[$i] < $xEmax){
	$xrate[@ch1[$i]][@ch2[$i]][@inlev[$i]] += @rate[$i];
	$xenergy[@ch1[$i]][@ch2[$i]][@inlev[$i]] += @rate[$i]*@energy[$i];
	$xsw[@ch1[$i]][@ch2[$i]][@inlev[$i]] = @sw[$i];
	$i++;
    }
}
$imax = $i - 1;
close $fh1;

for($ch1=0;$ch1<=$xch1max;$ch1++){
    for($ch2=0;$ch2<=$xch2max;$ch2++){
	$xswsum = 0;
	for($inlev=0;$inlev<=$inlevmax;$inlev++){
	    if($xrate[$ch1][$ch2][$inlev]){
		$xratew[$ch1][$ch2] += $xrate[$ch1][$ch2][$inlev] * $xsw[$ch1][$ch2][$inlev];
		$xenergyw[$ch1][$ch2] += $xenergy[$ch1][$ch2][$inlev] * $xsw[$ch1][$ch2][$inlev] / $xrate[$ch1][$ch2][$inlev];
		$xswsum += $xsw[$ch1][$ch2][$inlev];
		#print "$ch1 \t $ch2 \t $inlev \t $xrate[$ch1][$ch2][$inlev] \t $xsw[$ch1][$ch2][$inlev] \n";
	    }
	}
	if($xswsum){
	    $xratew[$ch1][$ch2] = $xratew[$ch1][$ch2] / $xswsum;
	    $xratewsum[$ch1] += $xratew[$ch1][$ch2];
	    $xenergyw[$ch1][$ch2] = $xenergyw[$ch1][$ch2] / ($xswsum*1000000);
	    #print "$ch1 \t $ch2 \t $xratew[$ch1][$ch2]  \t $xenergyw[$ch1][$ch2] \n";
	}
    }
}

# PRINT TO FILE - AUGER

open $fh1, '>', "augertrans_rdr.dat" or die $!;
open $fh2, '>', "augerabsrate_rdr.dat" or die $!;
open $fh3, '>>', "augertrans_tot_rdr.dat" or die $!;
for($i=0;$i<=$ach1max;$i++){
    $flag = 0;
    #print $fh3 "$i \t",$aratewsum[$i] * 6.5821e-22,"\n" if($aratewsum[$i]);         # line width in MeV
    printf $fh3 (" %.5E %.5E\n",$i,$aratewsum[$i] * 6.5821e-22) if($aratewsum[$i]); # line width in MeV
    for($j=0;$j<=$ach2max;$j++){
	for($k=0;$k<=$ach3max;$k++){
	    if($aratew[$i][$j][$k]){
		if(!$flag){
		    #print $fh1 "$i \n";
		    printf $fh1 (" %.5E\n",$i);
		    $flag = 1;
		}
		#print $fh1 "$j \t $k \t", $aratew[$i][$j][$k]/($aratewsum[$i] + $xratewsum[$i]) ,"\t", $aenergyw[$i][$j][$k] ,"\n";
		printf $fh1 (" %.5E %.5E %.5E %.5E\n",$j,$k,$aratew[$i][$j][$k]/($aratewsum[$i] + $xratewsum[$i]),$aenergyw[$i][$j][$k]);
		#print $fh2 "$i \t $j \t $k \t", $aratew[$i][$j][$k] ,"\t", 1000000 * $aenergyw[$i][$j][$k] , "\n";
		printf $fh2 ("%4d%4d%4d %.5E %.5E\n",$i,$j,$k,$aratew[$i][$j][$k],1000000 * $aenergyw[$i][$j][$k]);
	    }
	}
    }
}
close $fh1;
close $fh2;
close $fh3;

# PRINT TO FILE - X-RAY

open $fh1, '>', "trans_rdr.dat" or die $!;
open $fh2, '>', "transabsrate_rdr.dat" or die $!;
open $fh3, '>>', "trans_tot_rdr.dat" or die $!;
for($i=0;$i<=$xch1max;$i++){
    $flag = 0;
    #print $fh3 "$i \t",$xratewsum[$i] * 6.5821e-22,"\n" if($xratewsum[$i]);         # line width in MeV
    printf $fh3 (" %.5E %.5E\n",$i,$xratewsum[$i] * 6.5821e-22) if($xratewsum[$i]); # line width in MeV
    for($j=0;$j<=$xch2max;$j++){
	if($xratew[$i][$j]){
	    if(!$flag){
		#print $fh1 "$i \n";
		printf $fh1 (" %.5E\n",$i);
		$flag = 1;
	    }
	    #print $fh1 "$j \t", $xratew[$i][$j]/($aratewsum[$i] + $xratewsum[$i]) ,"\t", $xenergyw[$i][$j] ,"\n";
	    printf $fh1 (" %.5E %.5E %.5E\n",$j,$xratew[$i][$j]/($aratewsum[$i] + $xratewsum[$i]),$xenergyw[$i][$j]);
	    #print $fh2 "$i \t $j \t", $xratew[$i][$j] ,"\t", 1000000 * $xenergyw[$i][$j] , "\n";
	    printf $fh2 ("%4d%4d %.5E %.5E\n",$i,$j,$xratew[$i][$j],1000000 * $xenergyw[$i][$j]);   
	}
    }
}
close $fh1;
close $fh2;
close $fh3;
