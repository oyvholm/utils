#!/usr/bin/perl

# $Id: index.cgi,v 1.1 1999/04/08 14:59:25 sunny Exp $
# Test-index.cgi som ikke skal brukes til noe annet enn testing av tricgi.pm

require tricgi;

$WebMaster="jeg\@er.snill.edu";
$cvs_id = '$Id: index.cgi,v 1.1 1999/04/08 14:59:25 sunny Exp $';
$counter_file = "counter.txt";
$error_file = "errorfile.txt";
$Url = "index.cgi";

%Opt = &tricgi::get_cgivars();
&tricgi::print_doc("test.shtml");
printf "get_countervalue(\"$counter_file\") før increase: %s\n", &tricgi::get_countervalue($counter_file);
&tricgi::increase_counter("counter.txt");
printf "get_countervalue(\"$counter_file\") etter increase: %s\n", &tricgi::get_countervalue($counter_file);
&tricgi::tab_print(<<END);
Hei og hå. her har vi æøåÆØÅ og ¢©@¹@£¡££$£¡ masse drit kort sagt.
127: 
128: €
255: ÿ
æææææææææææææææææææææææææææææææææææææææææææææææææææææææææææææææææææææææææææææææææææææææææææææææææææææææææææææææææææææææææææææææææææææææææææææææææææææææææææææææææææææææææææææææææææææææææææææææææææææææææææææææææææææææææææææææææææææææææææææææææææææææææææææææææææææææææææææææææææææææææææææææææææææææææææææææææææææææææææææææææææææææææææææææææææææææææææææææææææææææææææææææææææææææææææææææææææææææææææææææææææææææææææææææææææææææææææææææææææææææææææææææææææææææææææææææææææææææææææææææææææææææææææææææææææ
yah
END
exit;

##############################

&tricgi::print_header("Yess man");

print "print her, og $Tabs = $tricgi::Tabs\n";
&tricgi::tab_print("Heia\n");
&tricgi::Tabs(2);
print "print her, og $Tabs = $tricgi::Tabs\n";
&tricgi::tab_print("Heia\n");
print "local Tabs = $Tabs\n";

#### End of file $Id: index.cgi,v 1.1 1999/04/08 14:59:25 sunny Exp $ ####
