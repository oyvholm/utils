#!/usr/bin/perl

# $Id: index.cgi,v 1.2 2000/09/01 10:38:33 sunny Exp $
# Test-index.cgi som ikke skal brukes til noe annet enn testing av suncgi.pm

use suncgi;

$WebMaster="jeg\@er.snill.edu";
$rcs_id = '$Id: index.cgi,v 1.2 2000/09/01 10:38:33 sunny Exp $';
$counter_file = "counter.txt";
$error_file = "errorfile.txt";
$Url = "index.cgi";

%Opt = get_cgivars();
print_doc("test.shtml");
printf "get_countervalue(\"$counter_file\") før increase: %s\n", get_countervalue($counter_file);
increase_counter("counter.txt");
printf "get_countervalue(\"$counter_file\") etter increase: %s\n", get_countervalue($counter_file);
tab_print(<<END);
Hei og hå. her har vi æøåÆØÅ og ¢©@¹@£¡££$£¡ masse drit kort sagt.
127: 
128: €
255: ÿ
æææææææææææææææææææææææææææææææææææææææææææææææææææææææææææææææææææææææææææææææææææææææææææææææææææææææææææææææææææææææææææææææææææææææææææææææææææææææææææææææææææææææææææææææææææææææææææææææææææææææææææææææææææææææææææææææææææææææææææææææææææææææææææææææææææææææææææææææææææææææææææææææææææææææææææææææææææææææææææææææææææææææææææææææææææææææææææææææææææææææææææææææææææææææææææææææææææææææææææææææææææææææææææææææææææææææææææææææææææææææææææææææææææææææææææææææææææææææææææææææææææææææææææææææææææ
yah
END
exit;

##############################

print_header("Yess man");

print "print her, og $Tabs = $suncgi::Tabs\n";
tab_print("Heia\n");
Tabs(2);
print "print her, og $Tabs = $suncgi::Tabs\n";
tab_print("Heia\n");
print "local Tabs = $Tabs\n";

#### End of file $Id: index.cgi,v 1.2 2000/09/01 10:38:33 sunny Exp $ ####
