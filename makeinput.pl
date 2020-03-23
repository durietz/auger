#!/usr/bin/perl
#use strict;
#use warnings;

# frozen core approximation

# User specified input data
#print "Element (e.g. Xe)?  ";
#chomp($element = <>);
#@dummysplit = split(' ',$element);
#$element = @dummysplit[0];

print "Give configuration of system before initial vacancy?  ";
chomp($inconf = <>);

print "Initial vacancy subshell (eg K)?  ";
chomp($invac = <>);
@dummysplit = split(' ',$invac);
$invac = @dummysplit[0];

printf("\n");
print "Estimated wave function file?  ";
chomp($rwfnest = <>);

# defintions of some arrays and hashtags for subshell to transition conversions etc.
&hashtags;

# extract nonrelativistic orbits, occupation numbers and parities
@orb = split('\)', $inconf);
$nss = scalar(@orb);
for ($i=0; $i<$nss; $i++){
    @orbsplit = split('\(', @orb[$i]);
    @ssocc[$i] = @orbsplit[1];
    $length = length(@orbsplit[0]);
    if($length == 2){
	@ssn[$i] = substr(@orbsplit[0], 0, 1);
	@ssl[$i] = substr(@orbsplit[0], 1, 1);
	@ssnl[$i] = substr(@orbsplit[0], 0, 2);
    }elsif($length == 3){
	@ssn[$i] = substr(@orbsplit[0], 0, 2);
	@ssl[$i] = substr(@orbsplit[0], 2, 1);
	@ssnl[$i] = substr(@orbsplit[0], 0, 3);
    }
    if($invac ne "ALL"){
	if($testhash2{$invac} eq @ssnl[$i]){
	    $imina = $i;
	    $iminr = $i;
	    #printf("@ssnl[$i]  $testhash2{$invac}\n");
	}
    }
    # printf("@ssnl[$i]  $testhash1b{@ssnl[$i]}  @ssocc[$i]\n");
}

if($invac ne "ALL"){
    $iimin = $imina;
    $iimax = $imina + 1;
}else{
    $iimin = 0;
    $iimax = $nss;
}

# Determine auger transitions
$nauger = 0;
for ($ii=$iimin; $ii<$iimax; $ii++){
for ($i=$ii; $i<$nss; $i++){
    for ($j=$i; $j<$nss; $j++){
	if($i == $ii){
	    $length = length($testhash1b{@ssnl[$i]});
	    if($length > 2){
		if($i == $j){
		    if(@ssocc[$i] >= 2){
			# printf("$invac-$testhash1b{@ssnl[$i]}-$testhash1b{@ssnl[$j]}\n");
			$nauger = $nauger + 1;
		    }
		}else{
		    if(@ssocc[$i] >= 1 && @ssocc[$j] >= 1){
			# printf("$invac-$testhash1b{@ssnl[$i]}-$testhash1b{@ssnl[$j]}\n");
			$nauger = $nauger + 1;
		    }
		}
	    }
	}else{
	    if($i == $j){
		if(@ssocc[$i] >= 2){
		    # printf("$invac-$testhash1b{@ssnl[$i]}-$testhash1b{@ssnl[$j]}\n");
		    $nauger = $nauger + 1;
		}
	    }else{
		if(@ssocc[$i] >= 1 && @ssocc[$j] >= 1){
		    # printf("$invac-$testhash1b{@ssnl[$i]}-$testhash1b{@ssnl[$j]}\n");
		    $nauger = $nauger + 1;
		}
	    }
	}
	#printf("@ssnl[$i]  $testhash1b{@ssnl[$i]}  @ssocc[$i]\n");
    }
}
}
# Determine radiative E1 transitions
$nrad = 0;
for ($ii=$iimin; $ii<$iimax; $ii++){
for ($i=$ii; $i<$nss; $i++){
    if($i == $ii){
	$length = length($testhash1b{@ssnl[$i]});
	if($length > 2){
	    if(@ssocc[$i] >= 2){
		# printf("$invac-$testhash1b{@ssnl[$i]}\n");
		$nrad = $nrad + 1;
	    }
	}
    }else{
	if(@ssocc[$i] >= 1){
	    # printf("$invac-$testhash1b{@ssnl[$i]}\n");
	    $nrad = $nrad + 1;
	}
    }
}
}

# construct input file for auger transitions
$inpfile = "inp_auger_${invac}";
open (FILE,'>',$inpfile);
#print FILE "$element          \# Give element (E.g. Xe)\n";
print FILE "$inconf      \# Give configuration of system before initial vacancy\n";
print FILE "$rwfnest     \# Estimated wave function file?\n";
print FILE "y            \# Recalculate existing initial states (y/n)?\n";
print FILE "y            \# Recalculate existing final states (y/n)?\n";
print FILE "y            \# Default rscf calculations for initial states (y/n)?\n";
print FILE "y            \# Default rscf calculations for final states (y/n)?\n";
print FILE "n            \# Calculate Auger transitions (y/n)?\n";
print FILE "$nauger            \# Give number of transitions to be calculated\n";
for ($ii=$iimin; $ii<$iimax; $ii++){
for ($i=$ii; $i<$nss; $i++){
    for ($j=$i; $j<$nss; $j++){
	if($i == $ii){
	    $length = length($testhash1b{@ssnl[$i]});
	    if($length > 2){
		if($i == $j){
		    if(@ssocc[$i] >= 2){
			#print FILE "$invac-$testhash1b{@ssnl[$i]}-$testhash1b{@ssnl[$j]}\n";
			print FILE "$testhash1b{@ssnl[$ii]}-$testhash1b{@ssnl[$i]}-$testhash1b{@ssnl[$j]}\n";
		    }
		}else{
		    if(@ssocc[$i] >= 1 && @ssocc[$j] >= 1){
			#print FILE "$invac-$testhash1b{@ssnl[$i]}-$testhash1b{@ssnl[$j]}\n";
			print FILE "$testhash1b{@ssnl[$ii]}-$testhash1b{@ssnl[$i]}-$testhash1b{@ssnl[$j]}\n";			
		    }
		}
	    }
	}else{
	    if($i == $j){
		if(@ssocc[$i] >= 2){
		    #print FILE "$invac-$testhash1b{@ssnl[$i]}-$testhash1b{@ssnl[$j]}\n";
		    print FILE "$testhash1b{@ssnl[$ii]}-$testhash1b{@ssnl[$i]}-$testhash1b{@ssnl[$j]}\n";		    
		}
	    }else{
		if(@ssocc[$i] >= 1 && @ssocc[$j] >= 1){
		    #print FILE "$invac-$testhash1b{@ssnl[$i]}-$testhash1b{@ssnl[$j]}\n";
		    print FILE "$testhash1b{@ssnl[$ii]}-$testhash1b{@ssnl[$i]}-$testhash1b{@ssnl[$j]}\n";		    
		}
	    }
	}
    }
}
}
close(FILE);

# construct input file for radiative transitions
$inpfile = "inp_rad_${invac}";
open (FILE,'>',$inpfile);
#print FILE "$element            \# Give element (E.g. Xe)\n";
print FILE "$inconf      \# Give configuration of system before initial vacancy\n";
print FILE "$rwfnest     \# Estimated wave function file?\n";
print FILE "y            \# Recalculate existing initial states (y/n)?\n";
print FILE "y            \# Recalculate existing final states (y/n)?\n";
print FILE "y            \# Default rscf calculations for initial states (y/n)?\n";
print FILE "y            \# Default rscf calculations for final states (y/n)?\n";
print FILE "n            \# Calculate radiative transitions (y/n)?\n";
print FILE "$nrad             \# Give number of transitions to be calculated\n";
for ($ii=$iimin; $ii<$iimax; $ii++){
for ($i=$ii; $i<$nss; $i++){
    if($i == $ii){
	$length = length($testhash1b{@ssnl[$i]});
	if($length > 2){
	    if(@ssocc[$i] >= 2){
		#print FILE "$invac-$testhash1b{@ssnl[$i]}\n";
		print FILE "$testhash1b{@ssnl[$ii]}-$testhash1b{@ssnl[$i]}\n";
	    }
	}
    }else{
	if(@ssocc[$i] >= 1){
	    #print FILE "$invac-$testhash1b{@ssnl[$i]}\n";
	    print FILE "$testhash1b{@ssnl[$ii]}-$testhash1b{@ssnl[$i]}\n";	    
	}
    }
}
}
close(FILE);

sub hashtags
{
    
@ssldef = ("s","p","d","f","g","h");

%testhash = (
    's' => 0,
    'p' => 1,
    'd' => 2,   
    'f' => 3,   
    'g' => 4,
    'h' => 5,   
    );

%testhash1b = (
    '1s' => 'K',
    '2s' => 'L1',
    '2p' => 'L23',   
    '3s' => 'M1',
    '3p' => 'M23',      
    '3d' => 'M45',
    '4s' => 'N1',
    '4p' => 'N23',      
    '4d' => 'N45',
    '4f' => 'N67',
    '5s' => 'O1',
    '5p' => 'O23',      
    '5d' => 'O45',
    '5f' => 'O67',
    '5g' => 'O89',
    '6s' => 'P1',
    '6p' => 'P23',
    '6d' => 'P45',
    '6f' => 'P67',
    '6g' => 'P89',
    '6h' => 'P1011',
    '7s' => 'Q1',
    '7p' => 'Q23',
    );

%testhash1c = (
    '1s' => '+',
    '2s' => '+',
    '2p' => '-',   
    '3s' => '+',
    '3p' => '-',      
    '3d' => '+',
    '4s' => '+',
    '4p' => '-',      
    '4d' => '+',
    '4f' => '-',
    '5s' => '+',
    '5p' => '-',      
    '5d' => '+',
    '5f' => '-',
    '5g' => '+',
    '6s' => '+',
    '6p' => '-',
    '6d' => '+',
    '6f' => '-',
    '6g' => '+',
    '6h' => '-',
    '7s' => '+',
    '7p' => '-',
    );

%testhash2 = (
    'K' => '1s',
    'L1' => '2s',
    'L23' => '2p',   
    'M1' => '3s',
    'M23' => '3p',      
    'M45' => '3d',
    'N1' => '4s',
    'N23' => '4p',      
    'N45' => '4d',
    'N67' => '4f',
    'O1' => '5s',
    'O23' => '5p',      
    'O45' => '5d',
    'O67' => '5f',
    'O89' => '5g',
    'P1' => '6s',
    'P23' => '6p',      
    'P45' => '6d',
    'P67' => '6f',
    'P89' => '6g',
    'P1011' => '6h',
    'Q1' => '7s',
    'Q23' => '7p',          
    );

%testhash4 = (
    'K' => '1s',
    'L1' => '2s',
    'L23' => '2p-',
    'M1' => '3s',
    'M23' => '3p-',      
    'M45' => '3d-',
    'N1' => '4s',
    'N23' => '4p-',      
    'N45' => '4d-',
    'N67' => '4f-',
    'O1' => '5s',
    'O23' => '5p-',      
    'O45' => '5d-',
    'O67' => '5f-',
    'O89' => '5g-',   
    );

%testhash4b = (
    'K' => '1s',
    'L1' => '2s',
    'L23' => '2p ',
    'M1' => '3s',
    'M23' => '3p ',      
    'M45' => '3d ',
    'N1' => '4s',
    'N23' => '4p ',      
    'N45' => '4d ',
    'N67' => '4f ',
    'O1' => '5s',
    'O23' => '5p ',      
    'O45' => '5d ',
    'O67' => '5f ',
    'O89' => '5g ',   
    );

%testhash5 = (
    'K' => 'K',
    'L1' => 'L1',
    'L23' => 'L2',   
    'M1' => 'M1',
    'M23' => 'M2',
    'M45' => 'M4',
    'N1' => 'N1',
    'N23' => 'N2',
    'N45' => 'N4',
    'N67' => 'N6',
    'O1' => 'O1',
    'O23' => 'O2',
    'O45' => 'O4',
    'O67' => 'O6',
    'O89' => 'O8',
    );

%testhash5b = (
    'K' => 'K',
    'L1' => 'L1',
    'L23' => 'L3',
    'M1' => 'M1',
    'M23' => 'M3',
    'M45' => 'M5',
    'N1' => 'N1',
    'N23' => 'N3',
    'N45' => 'N5',
    'N67' => 'N7',
    'O1' => 'O1',
    'O23' => 'O3',
    'O45' => 'O5',
    'O67' => 'O7',
    'O89' => 'O9',   
    );

%testhash6 = (
    'K' => '1',
    'L1' => '3',
    'L23' => '5',   
    'M1' => '8',
    'M23' => '10',
    'M45' => '13',
    'N1' => '16',
    'N23' => '18',
    'N45' => '21',
    'N67' => '24',
    'O1' => '27',
    'O23' => '29',
    'O45' => '32',
    'O67' => '35',
    'O89' => '38',
    );

%testhash6b = (
    'K' => '1',
    'L1' => '3',
    'L23' => '6',
    'M1' => '8',
    'M23' => '11',
    'M45' => '14',
    'N1' => '16',
    'N23' => '19',
    'N45' => '22',
    'N67' => '25',
    'O1' => '27',
    'O23' => '30',
    'O45' => '33',
    'O67' => '36',
    'O89' => '39',   
    );
}
