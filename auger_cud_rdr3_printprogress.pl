#!/usr/bin/perl
#use strict;
#use warnings;

# frozen core approximation

# Print to superlogfile whenever a systemcommand is executed. This because to try understand exactly how program is built up :)

open(PROGRESSLOG,'>','progress.log') or die $!;
print PROGRESSLOG scalar(localtime)."\t Starting auger_cud_rdr3_specialprinter \n";

# User specified input data
print "Give configuration of system before initial vacancy?  ";
chomp($inconf = <>);
@dummysplit = split(' ',$inconf);
$inconf = @dummysplit[0];

print "Estimated wave function file?  ";
chomp($rwfnest = <>);
@dummysplit = split(' ',$rwfnest);
$rwfnest = @dummysplit[0];

print "Recalculate existing initial states (y/n)?  ";
chomp($recalcstatesini = <>);
@dummysplit = split(' ',$recalcstatesini);
$recalcstatesini = @dummysplit[0];

print "Recalculate existing final states (y/n)?  ";
chomp($recalcstatesfin = <>);
@dummysplit = split(' ',$recalcstatesfin);
$recalcstatesfin = @dummysplit[0];

print "Default rscf calculations for initial states (y/n)?  ";
chomp($defaultini = <>);
@dummysplit = split(' ',$defaultini);
$defaultini = @dummysplit[0];

print "Default rscf calculations for final states (y/n)?  ";
chomp($defaultfin = <>);
@dummysplit = split(' ',$defaultfin);
$defaultfin = @dummysplit[0];

print "Calculate Auger transitions (y/n)?  ";
chomp($calcauger = <>);
@dummysplit = split(' ',$calcauger);
$calcauger = @dummysplit[0];

print "Give number of transitions to be calculated?  ";
chomp($ntrans = <>);
@dummysplit = split(' ',$ntrans);
$ntrans = @dummysplit[0];
for ($i=0; $i<$ntrans; $i++){  # loop over transitions
    $j = $i + 1;
    print "Give Auger transition $j (eg. K-L23-L23)?  ";
    chomp($transi[$i] = <>);
}

# defintions of some arrays and hashtags for subshell to transition conversions etc.
&hashtags;

# fix default reference configuration for initial vacancy
#$refconf = "   1s ( 1)  2s ( 2)  2p-( 2)  2p ( 4)  3s ( 2)  3p-( 2)  3p ( 2)";
#print $refconf,"\n";
print PROGRESSLOG scalar(localtime)."\t sub: get_refconf \n";
&get_refconf;   
@refconf1 = @tmprefconf1;
@refconf2 = @tmprefconf2;
#foreach(@refconf1) {print $_,"\n"};
#exit;

# loop over number of Auger transitions starts
for ($jj=0; $jj<$ntrans; $jj++){  # loop over transitions
    print PROGRESSLOG scalar(localtime)."\t Loop over transitions. Transition $jj out of max $ntrans \n";
    
    printf("\n");
    printf("\n");
    printf("ACHANNEL: $transi[$jj]\n");
    printf("\n");
    printf("\n");;
    print PROGRESSLOG scalar(localtime)."   --> \t CHANNEL: $transi[$jj] \n";

    #exit;    #### RDR while testing
    
    # splitting of transitions into components
    print PROGRESSLOG scalar(localtime)."\t sub: transsplit \n";
    &transsplit;

    # nameing initial and final states
    print PROGRESSLOG scalar(localtime)."\t sub: statenames \n";
    &statenames; 

    # check if states already exists
    print PROGRESSLOG scalar(localtime)."\t sub: checkstates \n";
    &checkstates;
    
    # setting flags controlling empty subshells and rscf default mode
    print PROGRESSLOG scalar(localtime)."\t sub: flagzero \n";
    &flagszero;
    
    # loop over initial and final states starts
    for ($ii=0; $ii<2; $ii++){
	print PROGRESSLOG scalar(localtime)."\t Loop over initial (=0) and final state (=1). State $ii \n";
	$cudflag = 1;
	
	printf("\n");
	printf("\n");
	if($ii == 0){
	    printf("INITIAL TRANSITION\n");
	    printf("DEFAULTINIFLAG: $defaultiniflag\n");
	    
	}elsif($ii == 1){
	    printf("FINAL TRANSITION\n");
	    printf("DEFAULTFINFLAG: $defaultfinflag\n");
	}
	printf("\n");

	# based on Auger transition, construct configuration of initial or final state
	print PROGRESSLOG scalar(localtime)."\t sub: construcconf \n";
	&constructconf;
	
	# check for empty subshells and remove these from array and determine maximum principal
	# quantum number for each l-symmetry present
	print PROGRESSLOG scalar(localtime)."\t sub: rcsfexitationprepare \n";
	&rcsfexcitationprepare;
	
	# construct input file for rcsfexcitation
	print PROGRESSLOG scalar(localtime)."\t sub: rcsfexitationinputconstruct \n";
	&rcsfexcitationinputconstruct;
	
	# run rcsfexciation and rcsfgenerate
	print PROGRESSLOG scalar(localtime)."\t SYSTEM: rcsfexcitation < input.log \n";
	system("rcsfexcitation < input.log");

	print PROGRESSLOG scalar(localtime)."\t SYSTEM: rcsfgenerate < excitationdata > testout \n";
	system("rcsfgenerate < excitationdata > testout");

	print PROGRESSLOG scalar(localtime)."\t SYSTEM: cp rcsf.out rcsf.inp \n";
	system("cp rcsf.out rcsf.inp");

	print PROGRESSLOG scalar(localtime)."\t SYSTEM: cp rcsf.out test.c \n";
	system("cp rcsf.out test.c");    # for jjcud
	
	# read block number, J and no of states for each block from 
	# output file from rcsfgenerate
	print PROGRESSLOG scalar(localtime)."\t sub: readblockinfo \n";
	&readblockinfo;
	
	if($cudflag == 1){

	    # construct input file for rcsfexcitation
	    print PROGRESSLOG scalar(localtime)."\t sub: rcsfexcitationinputconstruct2 (cudflag ==1) \n";
	    &rcsfexcitationinputconstruct2;
	    
	    # run rcsfexciation and rcsfgenerate
	    print PROGRESSLOG scalar(localtime)."\t SYSTEM: rcsfexciation < input2.log \n";
	    system("rcsfexcitation < input2.log");

	    print PROGRESSLOG scalar(localtime)."\t SYSTEM: rcsfgenerate < excitationdata \n";
	    system("rcsfgenerate < excitationdata");

	    print PROGRESSLOG scalar(localtime)."\t SYSTEM: cp rcsf.out rcsl.inp \n";
	    system("cp rcsf.out rcsl.inp");

	    print PROGRESSLOG scalar(localtime)."\t sub: jjcudinputconstruct (cudflag ==1) \n";
	    &jjcudinputconstruct;

	    # system("/Users/tsjoek/programs/grasp2Kdev8/bin/jjcud < input_jjcud");
	    print PROGRESSLOG scalar(localtime)."\t SYSTEM: jjcud < input_jjcud \n";
	    system("jjcud < input_jjcud");

	    #system("cp test_cud.c rcsf.inp");
	    print PROGRESSLOG scalar(localtime)."\t SYSTEM: cp test_cud.c test.c \n";
	    system("cp test_cud.c test.c");

	    print PROGRESSLOG scalar(localtime)."\t sub: jjcudinputconstruct (cudflag ==1) \n";
	    &jjcudinputconstruct;
	    # system("/Users/tsjoek/programs/grasp2Kdev8/bin/jjcud < input_jjcud");
	    print PROGRESSLOG scalar(localtime)."\t SYSTEM: jjcud < input_jjcud \n";
	    system("jjcud < input_jjcud");
	    print PROGRESSLOG scalar(localtime)."\t SYSTEM: cp test_cud.c rcsf.inp.c \n";
	    system("cp test_cud.c rcsf.inp");
	    
	    print PROGRESSLOG scalar(localtime)."\t sub: runrcsfblock (cudflag ==1) \n";
	    &runrcsfblock;
	    
	    print PROGRESSLOG scalar(localtime)."\t sub: readblockinfo2 (cudflag ==1) \n";
	    &readblockinfo2;
	}

	# check if peel shell orbitals in rcsf.inp is missing in configurations
	# save different peel shell lines for:
	#    1. Only peel shells present in configurations - for initial rscf calculation
	#    2. All peel shells present in non-canonical order - empty peel shell last - for rscf CI - 
        #       to have same number of subshells in initial and final state.
	#    sets flag $emptyshellflag = 1 if empty peel shell
	if($recalcstate[$ii] == 1){
	    print PROGRESSLOG scalar(localtime)."\t sub: peelshellcheck \n";
	    &peelshellcheck;
	}

	# if $emptyshellflag == 1
	#    1. >>cp rcsf.inp rcsf.inp.ratip
	#    2. construct rcsf.inp with only peel shells present in configurations
	#    3. construct rcsf.inp.noncan with all peel shells in non-canonical order - empty peel shell last
	if($emptyshellflag == 1 && $recalcstate[$ii] == 1){
	    print PROGRESSLOG scalar(localtime)."\t sub: construcrcsfinp \n";
	    &constructrcsfinp;
	}

	# construct input file for rangular
	if($recalcstate[$ii] == 1){
	    print PROGRESSLOG scalar(localtime)."\t sub: rangularinputconstruct \n";
	    &rangularinputconstruct;
	}
	
	# run rangular
	if($recalcstate[$ii] == 1){
	    print PROGRESSLOG scalar(localtime)."\t SYSTEM: rangular < input_rangular \n";
	    system("rangular < input_rangular");
	}
	# if second or more transition in list use better initial estimate of radial wave function
	if($jj > 0){
	    #$rwfnest = 'relwaveinp.w';
	}
	
	# construct input file for rwfnestimate
	if($recalcstate[$ii] == 1){
	    print PROGRESSLOG scalar(localtime)."\t sub: rwfnestimateinputconstruct \n";
	    &rwfnestimateinputconstruct;
	}
	
	# run rwfnestimate
	if($recalcstate[$ii] == 1){
	   print PROGRESSLOG scalar(localtime)."\t SYSTEM: rwfnestimate < input_rwfnestimate \n";
	   system("rwfnestimate < input_rwfnestimate");
	}
	# construct input file for rscf and run rscf
	# according to user input, rscf calculations are run in default or non-default moder
	if($recalcstate[$ii] == 1){
	    if($ii == 0){
		if($defaultiniflag == 1){
		    print PROGRESSLOG scalar(localtime)."\t sub: rcsfdefault \n";
		    &rscfdefault;
		}else{
		    print PROGRESSLOG scalar(localtime)."\t sub: rcsfnodefault \n";
		    &rscfnondefault;
		}
	    }else{
		if($defaultfinflag == 1){
		    print PROGRESSLOG scalar(localtime)."\t sub: rcsfdefault \n";
		    &rscfdefault;
		}else{
		    print PROGRESSLOG scalar(localtime)."\t sub: rcsfnodefault \n";
		    &rscfnondefault;
		}
	    }
	}
	# if $emptyshellflag == 1:
	#     1. >>cp rcsf.inp.noncan rcsf.inp
	#     2. run rangular
	#     3. construct input file for rwfnestimate where wave functions are read from initial.w or final.w
	#        and secondly are read from $rwfnest (some initial estimate)
	#     4. run rwfnestimate
        #     5. construct input file for rscf in CI mode
        #     6. run rscf in CI mode  
	if($emptyshellflag == 1 && $recalcstate[$ii] == 1){
	    print PROGRESSLOG scalar(localtime)."\t SYSTEM: cp rcsf.inp.noncan rcsf.inp \n";
	    system("cp rcsf.inp.noncan rcsf.inp");
	    print PROGRESSLOG scalar(localtime)."\t SYSTEM: rangular < input_rangular \n";
	    system("rangular < input_rangular");
	    print PROGRESSLOG scalar(localtime)."\t sub: rwfnestimateconstruct2 \n";
	    &rwfnestimateinputconstruct2;
	    print PROGRESSLOG scalar(localtime)."\t SYSTEM: rwfnestimate < input_rwfnestimate \n";
	    system("rwfnestimate < input_rwfnestimate");
	    print PROGRESSLOG scalar(localtime)."\t sub: rcsfemptyshell \n";
	    &rscfemptyshell;
	}
	
	# construct input file for rci with corrrect number of states for each block
	if($recalcstate[$ii] == 1){
	    print PROGRESSLOG scalar(localtime)."\t sub: rciinputconstruct \n";
	    &rciinputconstruct;
	}

	# run rci
	if($recalcstate[$ii] == 1){
	    print PROGRESSLOG scalar(localtime)."\t SYSTEM: rci < input_rci \n";
	    system("rci < input_rci");
	}

	# construct input file for jj2lsj
	if($recalcstate[$ii] == 1){
	    print PROGRESSLOG scalar(localtime)."\t sub: jj2lsjinputconstuct \n";
	    &jj2lsjinputconstruct;
	}

	# run jj2lsj
	if($recalcstate[$ii] == 1){
	    print PROGRESSLOG scalar(localtime)."\t SYSTEM: jj2lsj < input_jj2lsj \n";
	    system("jj2lsj < input_jj2lsj");
	}

	# construct input file and run rmixextract and read relativitic configurations of states
	print PROGRESSLOG scalar(localtime)."\t sub: rmixextract \n";
	&rmixextract;
	
	# construct input file for jjgen_ratip
	if($recalcstate[$ii] == 1){
	    print PROGRESSLOG scalar(localtime)."\t sub: jjgen_ratipinputconstruct \n";
	    &jjgen_ratipinputconstruct;
	}

	#run jjgen_ratip
	if($recalcstate[$ii] == 1){
	    print PROGRESSLOG scalar(localtime)."\t SYSTEM: jjgenratip < input_jjgen_ratip \n";
	    system("jjgen_ratip < input_jjgen_ratip");
	}
	
	# construct input file for cvtmixratip
	if($recalcstate[$ii] == 1){
	    print PROGRESSLOG scalar(localtime)."\t sub: cvtmixratipconstruct \n";
	    &cvtmixratipinputconstruct;
	}
	
	# run cvtmixratip
	if($recalcstate[$ii] == 1){
	    print PROGRESSLOG scalar(localtime)."\t SYSTEM: cvtmixratip < input_cvtmixratip \n";
	    system("cvtmixratip < input_cvtmixratip");
	}
	
	# loop over initial and final states ends	
    }
    if($calcauger eq "y"){
	# construct input file for xauger
	print PROGRESSLOG scalar(localtime)."\t sub: xaugerinputconstruct \n";
	&xaugerinputconstruct;
	
	# run xauger
	print PROGRESSLOG scalar(localtime)."\t SYSTEM: xauger < input_xauger \n";
	system("xauger < input_xauger");
	
	# construct file designator.dat (for checking purposes solely) and use relativistic configurations 
	# from rmixextract to deduce transitions in relativistic notation
	print PROGRESSLOG scalar(localtime)."\t sub: designator \n";
	&designator;
	
	print PROGRESSLOG scalar(localtime)."\t sub: readtrnfile \n";
	&readtrnfile;
	
	# read energies and auger rates from xauger .sum file
	print PROGRESSLOG scalar(localtime)."\t sub: readxaugersum \n";
	&readxaugersum;
	
	# write (in append mode) channels, energies, rates and initial and final state configurations to file augertrans.out
	print PROGRESSLOG scalar(localtime)."\t sub: writetransdata \n";
	&writetransdata;
    }
    
    # loop over transitions ends
}

####################
# SUBROUTINES
####################
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

    %testhash1 = (
	's' => 2,
	'p' => 6,
	'd' => 10,   
	'f' => 14,   
	'g' => 18,
	'h' => 22,   
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

sub transsplit
{
    $trans = $transi[$jj];
    @transition = split('\-', $trans);
    $invac = @transition[0];
    $finvac1 = @transition[1];
    $finvac2 = @transition[2];
    $finvac = "${finvac1}-${finvac2}"
}

sub statenames
{
    $initialstate = "${invac}_initial";
    $initialstate1 = "${invac}_initial_e";
    $initialstatem = "${invac}_initial.m";
    $initialstatew = "${invac}_initial.w";
    $initialstatew1 = "${invac}_initial_e.w";
    $initialstatec = "${invac}_initial.c";
    $finalstate = "${finvac}_final";
    $finalstate1 = "${finvac}_final_e";
    $finalstatem = "${finvac}_final.m";
    $finalstatew = "${finvac}_final.w";
    $finalstatew1 = "${finvac}_final_e.w";
    $finalstatec = "${finvac}_final.c";
}
sub checkstates
{
    if($recalcstatesini eq "y"){
	$recalcstate[0] = 1;
    }else{
	if(-e $initialstatew){
	    $recalcstate[0] = 0;
	    printf("FILE $initialstatew EXISTS\n");
	}else{
	    printf("FILE $initialstatew DOES NOT EXISTS\n");
	    $recalcstate[0] = 1;
	}
    }

    if($recalcstatesfin eq "y"){
	$recalcstate[1] = 1;
    }else{
	if(-e $finalstatew){
	    $recalcstate[1] = 0;
	    printf("FILE $finalstatew EXISTS\n");
	}else{
	    printf("FILE $finalstatew DOES NOT EXISTS\n");
	    $recalcstate[1] = 1;
	}
    }
}

sub flagszero
{
    $emptyshellflag = 0;
    
    if($defaultini eq "y"){
	$defaultiniflag = 1;
    }else{
	$defaultiniflag = 0;
    }

    if($defaultfin eq "y"){
	$defaultfinflag = 1;
    }else{
	$defaultfinflag = 0;
    }
}

sub constructconf
{
    @maxn = (0) x 5;
    $sumocc = 0; 
    @orb = split('\)', $inconf);
    $nss = scalar(@orb);
    @holes = (0) x $nss;
    for ($i=0; $i<$nss; $i++){
	@orbsplit = split('\(', @orb[$i]);
	@ssocc[$i] = @orbsplit[1];
	$sumocc = $sumocc + @ssocc[$i];
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

	@sslnum[$i]=$testhash{@ssl[$i]};
	
	if($ii == 0){  # if initial state
	    if($ssnl[$i] eq $testhash2{$invac}){
		@ssocc[$i]--;
		$sumocc--;
	    }
	}else{  # if final state
	    if($ssnl[$i] eq $testhash2{$finvac1}){
		@ssocc[$i]--;
		$sumocc--;
	    }
	    if($ssnl[$i] eq $testhash2{$finvac2}){
		@ssocc[$i]--;
		$sumocc--;
	    }
	}
    }
}

sub rcsfexcitationprepare
{
    print "RCSFEXCITATIONPREPARE STARTS\n";
    $maxin = 0;
    for ($i=0; $i<$nss; $i++){
    	if(@ssn[$i] > @maxn[@sslnum[$i]]){
	    @maxn[@sslnum[$i]] = @ssn[$i];
	}
	if(@ssn[$i] > $maxin){
	    $maxin = @ssn[$i];
	}
    }
    printf("MAXN = $maxin");
    
    for ($i=0; $i<$nss; $i++){
	if(@ssocc[$i] == 0){
	    $cudflag = 0;
	    $iempt = $i;
	    @sslnumempt = @sslnum[$i];
	    @ssnempt = @ssn[$i];
	    $nss--;
	    for ($j=$iempt; $j<$nss; $j++){
		$step = $j+1;
		@ssocc[$j] = @ssocc[$step];
		@ssn[$j] = @ssn[$step];
		@ssl[$j] = @ssl[$step];
		@sslnum[$j] = @sslnum[$step];
		@ssnl[$j] = @ssnl[$step];
	    }
	}
	printf("@ssnl[$i]\n");
	#if(@ssn[$i] > @maxn[@sslnum[$i]]){
	#    @maxn[@sslnum[$i]] = @ssn[$i];
	#}
    }
}

sub jjcudinputconstruct
{
    print "JJCUDINPUTCONSTRUCT STARTS\n";
    open (FILE, '>input_jjcud');
    print FILE "y\n";
    print FILE "test\n";
    print FILE "n\n";
    print FILE "n\n";
    print FILE "0\n";
    close(FILE);
}

sub runrcsfblock
{
    open (FILE, '>input_rcsfblock');
    print FILE "n\n";
    close(FILE);
    
    print PROGRESSLOG scalar(localtime)."\t\t subSYS: rcsfblock < input_rcsfblock > testout2 \n";
    system("rcsfblock < input_rcsfblock > testout2");
}

sub rcsfexcitationinputconstruct
{
    print "RCSFEXCITATIONINPUTCONSTRUCT STARTS\n";
    open (FILE, '>input.log');
    print FILE "0\n";
    print FILE "1\n";
    for ($i=0; $i<$nss; $i++){
	printf("@ssnl[$i]\(@ssocc[$i]\,i\)");
	print FILE "@ssnl[$i]\(@ssocc[$i]\,i\)";
    }
    printf("\n");
    print FILE "\n";
    for ($i=0; $i<5; $i++){
	if(@maxn[$i] > 0){
	    if(length($maxn[$i]) == 1){
		printf(" @maxn[$i]@ssldef[$i]\,");
		print FILE " @maxn[$i]@ssldef[$i]\,";
	    }elsif(length($maxn[$i]) == 2){
		printf("@maxn[$i]@ssldef[$i]\,");
		print FILE "@maxn[$i]@ssldef[$i]\,";
	    }
	}
    }
    printf("\n");
    print FILE "\n";
    if(($sumocc % 2) == 0){
	print FILE "0\,20\n";
    }else{
	print FILE "1\,29\n";
    }
    print FILE "0\n";
    print FILE "n\n";    
    close(FILE);
}

sub rcsfexcitationinputconstruct2
{
    print "RCSFEXCITATIONINPUTCONSTRUCT2 STARTS\n";
    open (FILE, '>input2.log');
    print FILE "0\n";
    print FILE "1\n";
    for ($i=0; $i<$nss; $i++){
	printf("@ssnl[$i]\(@ssocc[$i]\,*\)");
	print FILE "@ssnl[$i]\(@ssocc[$i]\,*\)";
    }
    printf("\n");
    print FILE "\n";
    for ($i=0; $i<5; $i++){
	if(@maxn[$i] > 0){
	    if(length($maxn[$i]) == 1){
		printf(" @maxn[$i]@ssldef[$i]\,");
		print FILE " @maxn[$i]@ssldef[$i]\,";
	    }elsif(length($maxn[$i]) == 2){
		printf("@maxn[$i]@ssldef[$i]\,");
		print FILE "@maxn[$i]@ssldef[$i]\,";
	    }
	}
    }
    printf("\n");
    print FILE "\n";
    print FILE "$j2min\,$j2max\n";
    print FILE "2\n";   # 2 excitations
    print FILE "n\n";    
    close(FILE);
}

sub peelshellcheck
{
    open(INPUTFILE1, 'rcsf.inp');
    $i=0;
    $itag = 1000;
    $ibl = 0;
    while(<INPUTFILE1>){
	my($line) = $_;
	chomp($line);
	$linecontent[$i] = $line;
	if($linecontent[$i] =~ /Peel/){
	    #printf("$linecontent[$i]\n");
	    $itag = $i+1;
	}
	if($i == $itag){
	    @css = split(' ', $linecontent[$i]);
	    $length = scalar(@css);
	    @fills = (0) x $length;
	    
	    #printf("$length\n");
	    for ($j=0; $j<$length; $j++){
		$checkss1[$j] = @css[$j];
		$checkss2[$j] = substr(@css[$j], 0, 2);
		#printf("@checkss[$j]\n");
		for ($k=0; $k<$nss; $k++){
		    if($checkss2[$j] eq @ssnl[$k]){
			@fills[$j] = 1;
		    }
		}
	    }
	    for ($j=0; $j<$length; $j++){
		if(@fills[$j] != 1){
		    $emptyshellflag = 1;
		    printf("EMPTY SHELL\n");
		    printf("$checkss2[$j]\n");
		    if($j == ($length - 1)){
			printf("LAST SHELL IS EMPTY\n");
			$linecontent2 = $linecontent[$i];
			$linecontent[$i] =~ s/$checkss1[$j]//g;  #if outcommented hole peel shell not removed from CSF list
		    }else{
			if(length($checkss1[$j]) == 2){
			    #printf("$linecontent[$i]\n");
			    $linecontent[$i] =~ s/$checkss1[$j]   //g;  #if outcommented hole peel shell not removed from CSF list
			    #printf("$linecontent[$i]\n");
			    $linecontent2 = $linecontent[$i]."   ".$checkss1[$j];
			}elsif(length($checkss1[$j]) == 3){
			    $linecontent[$i] =~ s/$checkss1[$j]  //g;  #if outcommented hole peel shell not removed from CSF list
			    $linecontent2 = $linecontent[$i]."   ".$checkss1[$j];
			}
		    }
		}
	    }
	    
	}
	$i++;
    }
    $imax = $i;
    close(INPUTFILE1);
}

sub constructrcsfinp
{
    print PROGRESSLOG scalar(localtime)."\t\t subSYS: cp rcsf.inp rcsf.inp.ratip \n";
    system("cp rcsf.inp rcsf.inp.ratip");
    open (FILE, '>rcsf.inp');
    for ($i=0; $i<$imax; $i++){
	print FILE "$linecontent[$i]\n";
    }
    close(FILE);
    print PROGRESSLOG scalar(localtime)."\t\t subSYS: cp rcsf.inp rcsf.inp.peelconfpresent \n";
    system("cp rcsf.inp rcsf.inp.peelconfpresent");
    
    open (FILE, '>rcsf.inp.noncan');
    for ($i=0; $i<$imax; $i++){
	if($i == 3){
	    print FILE "$linecontent2\n";
	}else{
	    print FILE "$linecontent[$i]\n";
	}
    }
    close(FILE);
}

sub rangularinputconstruct
{
    open (FILE, '>input_rangular');
    print FILE "y\n";
    close(FILE);
}

sub rwfnestimateinputconstruct
{
    open (FILE, '>input_rwfnestimate');
    print FILE "y\n";        # default setings
    print FILE "y\n";        # canonical order
    print FILE "1\n";        # user Grasp2K wave function
    print FILE "$rwfnest\n"; # name of wave function to be used ..
    print FILE "\*\n";       # .. for all subshells
    close(FILE);
}

sub readblockinfo
{
    print "READBLOCKINFO STARTS\n";
    open(INPUTFILE1, 'testout');
    $i=0;
    $itag = 1000;
    $ibl = 0;
    if($ii == 0){
	$sumstateinitial = 0;
    }else{
	$sumstatefinal = 0;
    }
    while(<INPUTFILE1>){
	my($line) = $_;
	chomp($line);
	$linecontent[$i] = $line;
	if($linecontent[$i] =~ /NCSF/){
	    #printf("$linecontent[$i]\n");
	    $itag = $i
	}
	if($i > $itag){
	    @block = split(' ', $linecontent[$i]);
	    $blockno[$ibl] = chomp(@block[0]);
	    #$blockj[$ibl] = chomp(@block[1]);
	    $blockj[$ibl] = @block[1];
	    $blockst[$ibl] = @block[2];
	    if($ii == 0){
		$sumstateinitial = $sumstateinitial + $blockst[$ibl];
	    }else{
		$sumstatefinal = $sumstatefinal + $blockst[$ibl];
	    }
	    $ibl++;
	}
	$i++;
    }
    $nblock = $ibl;
    close(INPUTFILE1);

    # Extract 2xJmin and 2xJmax
    if(($sumocc % 2) == 0){   # J even
	$j2min = 2*$blockj[0];
	$j2max = 2*$blockj[$nblock-1];
    }else{                    # J odd
	$len = length($blockj[0]);
	$len2 = length($blockj[$nblock-1]);
	#printf("$len\n");
	if($len == 4) {
	    $j2min = substr($blockj[0], 0, 1);
	}else{
	    $j2min = substr($blockj[0], 0, 2);
	}
	if($len2 == 4) {
	    $j2max = substr($blockj[$nblock-1], 0, 1);
	}else{
	    $j2max = substr($blockj[$nblock-1], 0, 2);
	}

    }
    printf("JMIN AND JMAX?\n");
    printf("$j2min\n");
    printf("$j2max\n");
}

sub readblockinfo2
{
    open(INPUTFILE1, 'testout2');
    $i=0;
    $itag = 1000;
    $ibl = 0;
    if($ii == 0){
	$sumstateinitial2 = 0;
    }else{
	$sumstatefinal2 = 0;
    }
    while(<INPUTFILE1>){
	my($line) = $_;
	chomp($line);
	$linecontent[$i] = $line;
	if($linecontent[$i] =~ /NCSF/){
	    #printf("$linecontent[$i]\n");
	    $itag = $i
	}
	if($i > $itag){
	    @block = split(' ', $linecontent[$i]);
	    $blockno2[$ibl] = chomp(@block[0]);
	    #$blockj[$ibl] = chomp(@block[1]);
	    $blockj2[$ibl] = @block[1];
	    $blockst2[$ibl] = @block[2];
	    if($ii == 0){
		$sumstateinitial2 = $sumstateinitial2 + $blockst2[$ibl];
	    }else{
		$sumstatefinal2 = $sumstatefinal2 + $blockst2[$ibl];
	    }
	    $ibl++;
	}
	$i++;
    }
    $nblock2 = $ibl;
    close(INPUTFILE1);
}

sub rscfdefault
{
    open (FILE, '>input_rscf');
    print FILE "y\n";
    for ($i=0; $i<$nblock; $i++){
	if($cudflag == 1){
	    $statemin = ($blockst2[$i] - $blockst[$i]) + 1;
	    print FILE "$statemin\-$blockst2[$i]\n";
	}else{
	    print FILE "1\-$blockst[$i]\n";
	}
    }
    if($nblock > 1) {
	print FILE "5\n";
    }
    print FILE "\*\n";
    print FILE "\*\n";
    print FILE "300\n";
    close(FILE);
    
    # run rscf twice and do rsave and rlevels
    print PROGRESSLOG scalar(localtime)."\t\t subSYS: rscf < input_rscf \n";
    system("rscf < input_rscf");
    print PROGRESSLOG scalar(localtime)."\t\t subSYS: cp rwfn.out rwfn.inp \n";
    system("cp rwfn.out rwfn.inp");
    print PROGRESSLOG scalar(localtime)."\t\t subSYS: rscf < input_rscf \n";
    system("rscf < input_rscf");
    if($ii == 0){
	if($emptyshellflag == 1){
	    print PROGRESSLOG scalar(localtime)."\t\t subSYS: rsave $initialstate1 \n";
	    system("rsave $initialstate1");
	}else{
	    print PROGRESSLOG scalar(localtime)."\t\t subSYS: rsave $initialstate \n";
	    system("rsave $initialstate");
	}
	
    }else{
	if($emptyshellflag == 1){
	    print PROGRESSLOG scalar(localtime)."\t\t subSYS: rsave $finalstate1 \n";
	    system("rsave $finalstate1");
	}else{
	    print PROGRESSLOG scalar(localtime)."\t\t subSYS: rsave $finalstate \n";
	    system("rsave $finalstate");
	}
    }
}

sub rscfnondefault
{
    # construct input file for rscf with corrrect number of states for each block
    open (FILE, '>input_rscf');
    print FILE "n\n";        # non-default settings
    print FILE "n\n";
    print FILE "n\n";
    print FILE "y\n";            # change accuracy
    print FILE "1\.e\-7\n";	 # new accuracy
    for ($i=0; $i<$nblock; $i++){
	$statemin = ($blockst2[$i] - $blockst[$i]) + 1;
	print FILE "$statemin\-$blockst2[$i]\n";
	#print FILE "1\-$blockst[$i]\n";
    }
    if($nblock > 1) {
	print FILE "5\n";
    }
    print FILE "\*\n";
    print FILE "\*\n";
    print FILE "600\n";
    print FILE "y\n";        # modify other defaults
    print FILE "n\n";        # modify amplitude within oscillations are disregarded
    #print FILE "0\.1\n";     # new amplitude
    print FILE "y\n";        # select different integration method for radial wavefunctions
    print FILE "\n";         # not method 1
    print FILE "\n";         # not method 2
    print FILE "\*\n";       # method 3 selected
    print FILE "\n";         # not method 4
    print FILE "n\n";
    print FILE "n\n";
    print FILE "n\n";
    print FILE "n\n";
    print FILE "n\n";
    print FILE "n\n";
    print FILE "1\n";        # Orthonomalisation order 1. Update order 2. Self consistency connected
    close(FILE);
    
    # run rscf and do rsave and rlevels
    print PROGRESSLOG scalar(localtime)."\t\t subSYS: rscf < input_rscf \n";
    system("rscf < input_rscf");
    if($ii == 0){
	print PROGRESSLOG scalar(localtime)."\t\t subSYS: rsave $initialstate \n";
	system("rsave $initialstate");
	print PROGRESSLOG scalar(localtime)."\t\t subSYS: rlevels $initialstatem \n";
	system("rlevels $initialstatem");
    }else{
	print PROGRESSLOG scalar(localtime)."\t\t subSYS: rsave $finalstate \n";
	system("rsave $finalstate");
	print PROGRESSLOG scalar(localtime)."\t\t subSYS: rlevels $finalstatem \n";
	system("rlevels $finalstatem");
	print PROGRESSLOG scalar(localtime)."\t\t subSYS: cp $finalstatew relwaveinp.w\n";
	system("cp $finalstatew relwaveinp.w");
    }
}

sub rwfnestimateinputconstruct2
{
    # construct input file for rwfnestimate
    open (FILE, '>input_rwfnestimate');
    print FILE "y\n";
    print FILE "n\n";
    print FILE "1\n";
    if($ii == 0){
	print FILE "$initialstatew1\n";
    }else{
	print FILE "$finalstatew1\n";
    }
    print FILE "\*\n";
    print FILE "1\n";
    print FILE "$rwfnest\n";
    print FILE "\*\n";
    close(FILE);
}

sub rscfemptyshell
{
    # construct input file for rscf with corrrect number of states for each block
    open (FILE, '>input_rscf');
    print FILE "y\n";
    for ($i=0; $i<$nblock; $i++){
	if($cudflag == 1){
	    $statemin = ($blockst2[$i] - $blockst[$i]) + 1;
	    print FILE "$statemin\-$blockst2[$i]\n";
	}else{
	    print FILE "1\-$blockst[$i]\n";
	}
    }
    if($nblock > 1) {
	print FILE "5\n";
    }
    print FILE "\n";
    print FILE "\*\n";
    print FILE "300\n";
    close(FILE);
    
    print PROGRESSLOG scalar(localtime)."\t\t subSYS: rscf < inout_rscf \n";
    system("rscf < input_rscf");
    if($ii == 0){
	print PROGRESSLOG scalar(localtime)."\t\t subSYS: rsave $initialstate \n";
	system("rsave $initialstate");
	
    }else{
	print PROGRESSLOG scalar(localtime)."\t\t subSYS: rsave $finalstate \n";
	system("rsave $finalstate");
    }
}

sub rciinputconstruct
{
    open (FILE, '>input_rci');
    print FILE "y\n";
    if($ii == 0){
	print FILE "$initialstate\n";
    }else{
	print FILE "$finalstate\n";
    }
    print FILE "y\n";
    print FILE "y\n";
    print FILE "1\.e\-6\n";
    print FILE "y\n";
    print FILE "y\n";
    print FILE "n\n";
    print FILE "n\n";
    print FILE "y\n";
    print FILE "$maxin\n";    
    for ($i=0; $i<$nblock; $i++){
	if($cudflag == 1){
	    $statemin = ($blockst2[$i] - $blockst[$i]) + 1;
	    print FILE "$statemin\-$blockst2[$i]\n";
	}else{
	    print FILE "1\-$blockst[$i]\n";
	}
    }
    close(FILE);
}

sub jj2lsjinputconstruct
{
    open (FILE, '>input_jj2lsj');
    if($ii == 0){
	print FILE "$initialstate\n";
    }else{
	print FILE "$finalstate\n";
    }
    print FILE "y\n";
    print FILE "y\n";
    close(FILE);
}

sub rmixextract
{
    open (FILE, '>input_rmixextract');
    if($ii == 0){
	print FILE "$initialstate\n";
    }else{
	print FILE "$finalstate\n";
    }
    print FILE "y\n";              # input from CI calculation?
    print FILE "0\.01\n";
    print FILE "y\n";
    close(FILE);
    if($ii == 0){
	print PROGRESSLOG scalar(localtime)."\t\t subSYS: rmixextract < input_rmixextract > rmixinitial \n";
	system("rmixextract < input_rmixextract > rmixinitial");
    }else{
	print PROGRESSLOG scalar(localtime)."\t\t subSYS: rmixextract < input_rmixextract > rmixfinal \n";
	system("rmixextract < input_rmixextract > rmixfinal");
    }
    
    if($ii == 0){
	open(INPUTFILE1, 'rmixinitial');
    }else{
	open(INPUTFILE1, 'rmixfinal');
    }
    $i=0;
    $j=0;
    $itag = 10000;
    while(<INPUTFILE1>){
	my($line) = $_;
	chomp($line);
	$linecontent[$i] = $line;
	if($linecontent[$i] =~ /Coefficients and CSF/){
	    #printf("$linecontent[$i]\n");
	    $itag = $i+3;
	}
	if($i == $itag){
	    if($ii == 0){
		$confinitial[$j] = $linecontent[$i];
		$j++;
	    }else{
		$conffinal[$j] = $linecontent[$i];
		$j++;
	    }    
	    printf("$linecontent[$i]\n");
	}
	$i++;
    }
    close(INPUTFILE1);
}

sub jjgen_ratipinputconstruct
{
    open (FILE, '>input_jjgen_ratip');
    if($ii == 0){
	print FILE "$initialstate\n";
	if($emptyshellflag == 1){
	    print PROGRESSLOG scalar(localtime)."\t\t subSYS: cp rcsf.inp.ratip $initialstatec \n";
	    system("cp rcsf.inp.ratip $initialstatec");
	}
    }else{
	print FILE "$finalstate\n";
	if($emptyshellflag == 1){
	    print PROGRESSLOG scalar(localtime)."\t\t subSYS: cp rcsf.inp.ratip $finalstatec \n";
	    system("cp rcsf.inp.ratip $finalstatec");
	}
    }    
    close(FILE);
}

sub cvtmixratipinputconstruct
{
    open (FILE, '>input_cvtmixratip');
    if($ii == 0){
	print FILE "$initialstate\n";
    }else{
	print FILE "$finalstate\n";
    }
    print FILE "y\n";
    print FILE "n\n";
    close(FILE);
}

sub xaugerinputconstruct
{
    open (FILE, '>input_xauger');
    print FILE "${trans}_auger.sum\n";
    print FILE "isodata\n";
    print FILE "eV\n";
    print FILE "20000\.\n";
    print FILE "y\n";
    print FILE "y\n";
    for ($i=1; $i <= $sumstateinitial2; $i++){
	print FILE "$i \- 0\n";
    }
    print FILE "\n";
    print FILE "y\n";
    print FILE "y\n";
    print FILE "n\n";
    print FILE "n\n";
    print FILE "n\n";
    print FILE "n\n";
    print FILE "n\n";
    print FILE "y\n";
    print FILE "n\n";
    print FILE "y\n";
    print FILE "y\n";
    print FILE "${trans}_auger.trn\n";
    print FILE "0\.\n";
    print FILE "0\.0\n";
    print FILE "8\n";
    print FILE "n\n";
    print FILE "n\n";
    print FILE "$initialstate.rc\n";
    print FILE "$finalstate.rc\n";
    print FILE "$initialstate.cmix\n";
    print FILE "$finalstate.cmix\n";
    print FILE "$initialstate.w\n";
    print FILE "$initialstate.w\n";  # frozen core approximation
    close(FILE);
}

sub designator
{
    open (FILE, '>>','designator.dat');
    $count = 0;
    for ($i=0; $i<$sumstateinitial; $i++){
	for ($j=0; $j<$sumstatefinal; $j++){
	    
	    $energy2[$count] = 0.0;
	    $rate2[$count] = 0.0;
	    $sw2[$count] = 0;
	    $transdataflag[$count] = 0;
	    
	    $refflag = 0;
	    $refflag2 = 0;
	    #print "-------------\n";
	    do{
		if($refflag == 1){
		    $confinitial[$i] =~ /($tmpinvac[$jj].\(.\d\))/;
		    $match = $1;                            # Need to add \( in string for next matchexpression to work 1s ( 1) --> 1s \( 1\)
		    $match =~s /\(/\\(/;
		    $match =~s /\)/\\)/;
		    #print $match,"\n";
		    
		    if($refconf1[$jj] =~ /$match/){
			$initconf[$i] = $refconf1[$jj];      # Match ok - use refconf from first array
		    }else{
			$initconf[$i] = $refconf2[$jj];     # No match - use refconf from second array
		    }
		    #$initconf[$i] = $refconf[$jj];         # First version ... obsolete? Should it be $jj for pick up correct refconf?
		    $refflag = 0;
		    $refflag2 = 1;
		}else{
		    $initconf[$i] = $confinitial[$i];
		    $refflag2 = 0;
		}
		
		for ($k=0; $k<3; $k++){
		    $channel2[$k] = 99;
		    #printf("\n");
		    #printf("$k      $confinitial[$i]    $conffinal[$j]\n");
		    
		    if(length(@transition[$k]) == 3){
			#if(@transition[$k] eq @transition[2]){
			$resulti = index($initconf[$i], $testhash4{@transition[$k]});
			$occi = substr($initconf[$i], $resulti+4, 2);
			if($conffinal[$j] =~ /$testhash4{@transition[$k]}/){
			    $resultf = index($conffinal[$j], $testhash4{@transition[$k]});
			    $occf = substr($conffinal[$j], $resultf+4, 2);
			}else{
			    $occf = 0;
			}
			$docc1 = $occi - $occf;
			#printf("$occi    $occf      $docc1\n");
			$resulti = index($initconf[$i], $testhash4b{@transition[$k]});
			$occi = substr($initconf[$i], $resulti+4, 2);
			if($conffinal[$j] =~ /$testhash4b{@transition[$k]}/){
			    $resultf = index($conffinal[$j], $testhash4b{@transition[$k]});
			    $occf = substr($conffinal[$j], $resultf+4, 2);
			}else{
			    $occf = 0;
			}
			#printf("Hejsan\n");
			#printf("$resultf\n");
			$docc2 = $occi - $occf;
			#printf("$occi    $occf      $docc2\n");
			if($k>0){
			    if($docc1 == 2){
				#printf("$testhash5{@transition[$k]}\n");
				@channel[$k] = $testhash5{@transition[$k]};
				@channel2[$k] = $testhash6{@transition[$k]};
			    }elsif($docc2 == 2){
				#printf("$testhash5b{@transition[$k]}\n");
				@channel[$k] = $testhash5b{@transition[$k]};
				@channel2[$k] = $testhash6b{@transition[$k]};
			    }elsif($docc1 == 1 && $docc2 == 1){
				if($k == 1){
				    #printf("$testhash5{@transition[$k]}\n");
				    @channel[$k] = $testhash5{@transition[$k]};
				    @channel2[$k] = $testhash6{@transition[$k]};
				}elsif($k==2){
				    #printf("$testhash5b{@transition[$k]}\n");
				    @channel[$k] = $testhash5b{@transition[$k]};
				    @channel2[$k] = $testhash6b{@transition[$k]};
				}
			    }elsif($docc1 == 1){
				#printf("$testhash5{@transition[$k]}\n");
				@channel[$k] = $testhash5{@transition[$k]};
				@channel2[$k] = $testhash6{@transition[$k]};
			    }elsif($docc2 == 1){
				#printf("$testhash5b{@transition[$k]}\n");
				@channel[$k] = $testhash5b{@transition[$k]};
				@channel2[$k] = $testhash6b{@transition[$k]};
			    }
			    if(($docc1 == 0 && ($docc2 >=0 && $docc2 <= 2 )) ||      #only check "allowed" channels re: occupation No.
			       ($docc1 == 1 && ($docc2 >=0 && $docc2 <= 1 )) ||
			       ($docc1 == 2 && $docc2 == 0 )){
			    }else{
				@channel2[$k] = 99;
			    }
			}else{
			    if($docc1 == -1){
				#printf("$testhash5{@transition[$k]}\n");
				@channel[$k] = $testhash5{@transition[$k]};
				@channel2[$k] = $testhash6{@transition[$k]};
			    }elsif($docc2 == -1){
				#printf("$testhash5b{@transition[$k]}\n");
				@channel[$k] = $testhash5b{@transition[$k]};
				@channel2[$k] = $testhash6b{@transition[$k]};
			    }			
			}
			#}
		    }else{
			$resulti = index($initconf[$i], $testhash4{@transition[$k]});
			$occi = substr($initconf[$i], $resulti+4, 2);
			if($conffinal[$j] =~ /$testhash4{@transition[$k]}/){
			    $resultf = index($conffinal[$j], $testhash4{@transition[$k]});
			    $occf = substr($conffinal[$j], $resultf+4, 2);
			}else{
			    $occf = 0;
			}
			$docc1 = $occi - $occf;
			if($k>0){
			    if($docc1 >= 1){
				#printf("$testhash5{@transition[$k]}\n");
				@channel[$k] = $testhash5{@transition[$k]};
				@channel2[$k] = $testhash6{@transition[$k]};
			    }
			}else{
			    if($docc1 == -1){
				#printf("$testhash5{@transition[$k]}\n");
				@channel[$k] = $testhash5{@transition[$k]};
				@channel2[$k] = $testhash6{@transition[$k]};
			    }
			}		
		    }    
		    if ($channel2[$k] == 99) {$refflag = 1};

		}
	    }while($refflag == 1 && $refflag2 == 0);   # If strange ID (=99) loop over all $k once more and use $refconf[$i] instead 
	    
	    print FILE "@channel2[0] @channel2[1] @channel2[2]     $initconf[$i]    $conffinal[$j]\n";

	    $channel40[$count] = $channel[0];
	    $channel41[$count] = $channel[1];
	    $channel42[$count] = $channel[2];
	    
	    $channel30[$count] = $channel2[0];
	    $channel31[$count] = $channel2[1];
	    $channel32[$count] = $channel2[2];
	    $confinitial2[$count] = $initconf[$i];
	    $conffinal2[$count] = $conffinal[$j];
	    $count++;
	} 
    }
    close(FILE);
}

sub readtrnfile
{
    $augerfile = "${trans}_auger.trn";
    open(INPUTFILE1, $augerfile);
    $i = 1;
    $j = 1;
    $itag = 1000;
    while(<INPUTFILE1>){
	my($line) = $_;
	chomp($line);
	$linecontent[$i] = $line;
	if($linecontent[$i] =~ /Number_of_channels/){
	    $itag = $i+2;
	}
	if($i >= $itag){
	    @channeldata = split(' ', $linecontent[$i]);
	    $asf_i[$j] = @channeldata[0];
	    $asf_f[$j] = @channeldata[1];
	    $lev_i[$j] = @channeldata[2];
	    $lev_f[$j] = @channeldata[3];
	    $lev2asfini[$lev_i[$j]] = $asf_i[$j];
	    $lev2asffin[$lev_f[$j]] = $asf_f[$j];	    
	    $twoj_i[$j] = @channeldata[4];
	    $twoj_f[$j] = @channeldata[5];
	    $par_i[$j] = @channeldata[6];
	    $par_f[$j] = @channeldata[7];
	    $ener_free[$j] = @channeldata[8];	
	    $kappa_free[$j] = @channeldata[9];
	    $phase_free[$j] = @channeldata[10];	
	    $amp_real_free[$j] = @channeldata[11];
	    $amp_im_free[$j] = @channeldata[12];
	    $amp_free[$j] = sqrt($amp_real_free[$j]**2+$amp_im_free[$j]**2);
	    
	    #print "$amp_real_free[$j] $amp_im_free[$j]\n";
	    #print "$linecontent[$i]\n";

	    if($twoj_f[$j] eq '0'){ $j_f[$j] = '0'};
	    if($twoj_f[$j] eq '2'){ $j_f[$j] = '1'};
	    if($twoj_f[$j] eq '4'){ $j_f[$j] = '2'};
	    if($twoj_f[$j] eq '3'){ $j_f[$j] = '3'};

	    if($twoj_f[$j] eq '1'){ $j_f[$j] = '1/2'};
	    if($twoj_f[$j] eq '3'){ $j_f[$j] = '3/2'};
	    if($twoj_f[$j] eq '5'){ $j_f[$j] = '5/2'};
	    if($twoj_f[$j] eq '7'){ $j_f[$j] = '7/2'};
	    if($twoj_f[$j] eq '9'){ $j_f[$j] = '9/2'};

	    $jp_f[$j] = $j_f[$j].$par_f[$j];
	    
	    $j++;
	}
	$i++
    }
    $nochan2 = $j - 1;
    #print "no of channels: $nochan2\n";
    close(INPUTFILE1);
}

sub readxaugersum
{
    open (FILE,'>>','xauger.out');
    $augerfile = "${trans}_auger.sum";
    open(INPUTFILE1, $augerfile);
    $i=0;
    $j=0;
    $itagmin = 10000;
    while(<INPUTFILE1>){
	my($line) = $_;
	chomp($line);
	$linecontent[$i] = $line;
	#printf("$linecontent[$i]\n");
	if($linecontent[$i] =~ /Individual and total/){
	    #printf("$linecontent[$i]\n");
	    $itagmin = $i+6;
	    $itagmin2 = $i+6;
	    $itagmax = $itagmin + $sumstateinitial*$sumstatefinal - 1;
	}
	if($i >= $itagmin && $i <= $itagmax){
	    #if($linecontent[$i] =~ /Individual and total/){
	    #if($i == $itagmin){
	    #    $energyflag = index($linecontent[$i], 'Energy');
	    #    $rateflag = index($linecontent[$i], 'ate');
	    #    printf("$energyflag\n");
	    #    printf("$rateflag\n");
	    #}elsif($i >= $itagmin2){
	    #if($i >= $itagmin){
	    @checksplit = split(' ', $linecontent[$i]);
	    $lengthauger = scalar(@checksplit);
	    #printf("NO OF ELEMENTS IN AUGER STRING: $lengthauger\n");
	    #if($i >= $itagmin && substr($linecontent[$i], 1, 5) ne '-----'){
	    if($i >= $itagmin && $lengthauger == 10){
		#$energy[$j] = substr($linecontent[$i], $energyflag, 11);
		#$rate[$j] = substr($linecontent[$i], $rateflag, 9);
		@augerdata = split(' ', $linecontent[$i]);
		$inistatenumber[$j] = @augerdata[0];
		$finstatenumber[$j] = @augerdata[2];
		$inistateno[$j] = $lev2asfini[$inistatenumber[$j]];
		$finstateno[$j] = $lev2asffin[$finstatenumber[$j]];		    
		$transno = ($inistateno[$j]-1)*$sumstatefinal + $finstateno[$j] - 1;
		$transdataflag[$transno] = 1;
		$angmom[$j] = @augerdata[3];
		$parity[$j] = @augerdata[4];
		$angmom2[$j] = @augerdata[5];
		$parity2[$j] = @augerdata[6];
		if($angmom[$j] eq '1/2'){$sw[$j] = 2}
		if($angmom[$j] eq '3/2'){$sw[$j] = 4}
		if($angmom[$j] eq '5/2'){$sw[$j] = 6}
		if($angmom[$j] eq '7/2'){$sw[$j] = 8}
		if($angmom[$j] eq '9/2'){$sw[$j] = 10}
		if($angmom[$j] eq '11/2'){$sw[$j] = 12}
		if($angmom[$j] eq '13/2'){$sw[$j] = 14}
		if($angmom[$j] eq '15/2'){$sw[$j] = 16}
		if($angmom[$j] eq '17/2'){$sw[$j] = 18}
		if($angmom[$j] eq '19/2'){$sw[$j] = 20}
		if($angmom[$j] eq '21/2'){$sw[$j] = 22}
		if($angmom[$j] eq '23/2'){$sw[$j] = 24}
		if($angmom[$j] eq '25/2'){$sw[$j] = 26}		
		if($angmom[$j] eq '0'){$sw[$j] = 1}
		if($angmom[$j] eq '1'){$sw[$j] = 3}
		if($angmom[$j] eq '2'){$sw[$j] = 5}
		if($angmom[$j] eq '3'){$sw[$j] = 7}
		if($angmom[$j] eq '4'){$sw[$j] = 9}
		if($angmom[$j] eq '5'){$sw[$j] = 11}
		if($angmom[$j] eq '6'){$sw[$j] = 13}
		if($angmom[$j] eq '7'){$sw[$j] = 15}
		if($angmom[$j] eq '8'){$sw[$j] = 17}
		if($angmom[$j] eq '9'){$sw[$j] = 19}
		if($angmom[$j] eq '10'){$sw[$j] = 21}
		if($angmom[$j] eq '11'){$sw[$j] = 23}
		if($angmom[$j] eq '12'){$sw[$j] = 25}
		if($angmom[$j] eq '13'){$sw[$j] = 27}				
		$energy[$j] = @augerdata[7];
		$rate[$j] = @augerdata[8];

		
		$initialno[$transno] = $inistateno[$j];
		$sw2[$transno] = $sw[$j];
		$energy2[$transno] = $energy[$j];
		$rate2[$transno] = $rate[$j];
		
		#index($confinitial[$i], $testhash4{@transition[$k]});
		#@augerdata = split('     ', $linecontent[$i]);
		printf FILE "$channel40[$transno]-$channel41[$transno]-$channel42[$transno] \& \$$angmom[$j]\^$parity[$j]\$ \&  \$$angmom2[$j]\^$parity2[$j]\$  \&  $energy[$j] \&  $rate[$j] \\\\ \n";
		$j++;
	    }
	}
	$i++
    }
    printf("NO OF ELEMENTS IN AUGER STRING: $lengthauger\n");
    close(INPUTFILE1);
    close(FILE);
    
}

sub writetransdata
{
    open (FILE,'>>','augertrans.out');
    $imax = $sumstateinitial*$sumstatefinal;
    #print FILE "Channel   S.w.     Energy         Rate               Initial conf\.                           Final conf\.\n";
    for ($i=0; $i<$imax; $i++){
	if($transdataflag[$i] > 0){
	    printf FILE "%-11s %-11s %-11s %-11s %-16s %-16s %-16s\n", $channel30[$i], $channel31[$i], $channel32[$i], $sw2[$i], $energy2[$i], $rate2[$i], $initialno[$i];
	    #	    printf FILE "%-11s %-11s %-11s %-11s %-16s %-16s %-61s %-61s\n", $channel30[$i], $channel31[$i], $channel32[$i], $sw2[$i], $energy2[$i], $rate2[$i],$confinitial2[$i],$conffinal2[$i];
	}
    }
    close(FILE);

    open (FILE,'>>','augertrans_check.out');
    $imax = $sumstateinitial*$sumstatefinal;
    for ($i=0; $i<$imax; $i++){
	if($transdataflag[$i] > 0){
	    printf FILE "%-11s %-11s %-11s %-5s %-11s %-5s %-11s %-16s %-16s\n", $channel30[$i], $channel31[$i], $channel32[$i], $angmom[$i], $parity[$i], $angmom2[$i], $parity2[$i], $energy2[$i], $rate2[$i];
	    printf FILE "%-100s\n", $confinitial2[$i];
	    printf FILE "%-100s\n", $conffinal2[$i];	    
	    printf FILE "\n"; 
	}
    }
    close(FILE);
}

sub get_refconf(){    
    #print $inconf,"\n";
    #$inconf =~ /(\d+\w\(\d+\))/g;    
    
    @orbitals = ($inconf =~ /(\d+\w\(\d+\))/g);                  # extraxt orbitals from inconf e.g. 1s(2)2s(2) --> 1s(2) 2s(2)
    #print join (" ",@orbitals), " \n";
    
    $inconforig = " ";
    foreach(@orbitals){
	$_ =~/(\d+)(\w)\((\d+)\)/;                               # extract n=$1, l=$2, occupancy=$3 e.g. 1s(2) --> $1=1, $2=s, $3=2
	$inconforig .= '  ';        
	if($testhash{$2}){                                       # if not s-orbital split into two e.g. 2p --> 2p- and 2p 
	    $inconforig .= $1;
	    $inconforig .= $2.'-';
	    if($3 > $testhash{$2}*2){                            # check max occupany and fill accordingly
		$inconforig .= '( '.($testhash{$2}*2).')  ';
	    }else{
		$inconforig .= '( '.($3).')';
		next;
	    }
	}
	$inconforig .= $1;
	$inconforig .= $2.' ';
	$inconforig .= '( '.($3-$testhash{$2}*2).')';
    }
    $inconforig =~s/\s(\d\d)/$1/g;                               # fix if occupany too long e.g. ( 11) --> (11)    

    #print "$inconforig\n";	
    #print $refconf,"\n";
    #print $transi[0],"\n";
    
    foreach(@transi){
	($a,$b,$c) = split('\-',$_);                             # extract channels K-L1-M23 --> $a=K, $b=L1, $c=M23
	$d = $testhash2{$a};                                     # find what to match and replace in next step
	#print $d,"\n";
	
	# use one newrefconf, depending on where to put "hole" for split orbitals	
	$newrefconf1 = $inconforig =~s/$d(.?)\((\s?)(\d+)\)/"$d$1($2".($3-1).")" /re;     # refconfig e.g. L23 --> 2p-(1) 2p (4)
	$newrefconf2 = $inconforig =~s/$d(\s?)\((\s?)(\d+)\)/"$d$1($2".($3-1).")" /re;    # refconfig e.g. L23 --> 2p (2) 2p (3)

	#print $inconforig,"\n";
	#print $newrefconf,"\n";

	push @tmpinvac,$d;
	push @tmprefconf1,$newrefconf1;
	push @tmprefconf2,$newrefconf2;
    }
    return @tmprefconf1;
}
