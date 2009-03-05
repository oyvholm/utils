#!/usr/bin/perl -w

#=======================================================================
# $Id$
# File ID: 7a006334-f988-11dd-8845-000475e441b9
# Test suite for suuid(1).
#
# Character set: UTF-8
# ©opyleft 2008– Øyvind A. Holm <sunny@sunbase.org>
# License: GNU General Public License version 2 or later, see end of 
# file for legal stuff.
#=======================================================================

BEGIN {
    # push(@INC, "$ENV{'HOME'}/bin/STDlibdirDTS");
    our @version_array;
    use Test::More qw{no_plan};
    # use_ok() goes here
}

use strict;
use Getopt::Long;

$| = 1;

our $Debug = 0;
our $CMD = "../suuid";
our $cmdprogname = $CMD;
$cmdprogname =~ s/^.*\/(.*?)$/$1/;

our %Opt = (

    'all' => 0,
    'debug' => 0,
    'help' => 0,
    'todo' => 0,
    'verbose' => 0,
    'version' => 0,

);

our $progname = $0;
$progname =~ s/^.*\/(.*?)$/$1/;

my $rcs_id = '$Id$';
my $id_date = $rcs_id;
$id_date =~ s/^.*?\d+ (\d\d\d\d-.*?\d\d:\d\d:\d\d\S+).*/$1/;

push(@main::version_array, $rcs_id);

my @cmdline_array = @ARGV;

Getopt::Long::Configure("bundling");
GetOptions(

    "all|a" => \$Opt{'all'},
    "debug" => \$Opt{'debug'},
    "help|h" => \$Opt{'help'},
    "todo|t" => \$Opt{'todo'},
    "verbose|v+" => \$Opt{'verbose'},
    "version" => \$Opt{'version'},

) || die("$progname: Option error. Use -h for help.\n");

$Opt{'debug'} && ($Debug = 1);
$Opt{'help'} && usage(0);
if ($Opt{'version'}) {
    print_version();
    exit(0);
}

$ENV{'SESS_UUID'} = "";

diag(sprintf("========== Executing \"%s%s%s\" ==========",
    $progname,
    scalar(@cmdline_array) ? " " : "",
    join(" ", @cmdline_array)));

my $Outdir = "tmp-suuid-t-$$-" . substr(rand, 2, 8);
if (-e $Outdir) {
    die("$progname: $Outdir: WTF?? Directory element already exists.");
}
unless (mkdir($Outdir)) {
    die("$progname: $Outdir: Cannot mkdir(): $!\n");
}

if ($Opt{'todo'} && !$Opt{'all'}) {
    goto todo_section;
}

=pod

testcmd("$CMD command", # {{{
    <<END,
[expected stdin]
END
    "",
    "description",
);

# }}}

=cut

diag("Testing -h (--help) option...");
likecmd("$CMD -h", # {{{
    '/  Show this help\./',
    '/^$/',
    "Option -h prints help screen",
);

# }}}
ok(`$CMD -h` !~ /\$Id: /s, "\"$CMD -h\" - No Id with only -h");
diag("Testing -v (--verbose) option...");
likecmd("$CMD -hv", # {{{
    '/\$Id: .*? \$.*  Show this help\./s',
    '/^$/',
    "Option --version with -h returns Id string and help screen",
);

# }}}
diag("Testing --version option...");
likecmd("$CMD --version", # {{{
    '/\$Id: .*? \$/',
    '/^$/',
    "Option --version returns Id string",
);

# }}}
my $Lh = "[0-9a-fA-F]";
my $Templ = "$Lh\{8}-$Lh\{4}-$Lh\{4}-$Lh\{4}-$Lh\{12}";
my $v1_templ = "$Lh\{8}-$Lh\{4}-1$Lh\{3}-$Lh\{4}-$Lh\{12}";
my $v1rand_templ = "$Lh\{8}-$Lh\{4}-1$Lh\{3}-$Lh\{4}-$Lh\[37bf]$Lh\{10}";
my $date_templ = '20[0-9][0-9]-[0-1][0-9]-[0-3][0-9]T[0-2][0-9]:[0-5][0-9]:[0-6][0-9]\.\d+Z';
diag("No options (except --logfile)...");
likecmd("$CMD -l $Outdir", # {{{
    "/^$v1_templ\n\$/s",
    '/^$/',
    "No options (except -l) sends UUID to stdout",
);

# }}}
my $Outfile = glob("$Outdir/*");
like($Outfile, "/^$Outdir\\/$Lh\{12}\$/", "Filename of logfile OK");
like(file_data($Outfile), # {{{
    '/^' . join(' ',
        "<suuid t=\"$date_templ\" u=\"$v1_templ\">",
            "<cwd>.+?<\\/cwd>",
            "<user>.+<\\/user>",
            "<tty>.+<\\/tty>",
        "<\\/suuid>",
    ) . '\n$/s',
    "Log contents OK after exec with no options",
);

# }}}
system("$CMD -l $Outdir >/dev/null");
like(file_data($Outfile), # {{{
    '/^(' . join(' ',
        "<suuid t=\"$date_templ\" u=\"$v1_templ\">",
            "<cwd>.+?<\\/cwd>",
            "<user>.+<\\/user>",
            "<tty>.+<\\/tty>",
        "<\\/suuid>",
    ) . '\n){2}$/s',
    "Entries are added, not replacing",
);

# }}}
unlink($Outfile) || warn("$progname: $Outfile: Cannot delete file: $!\n");
diag("Read the environment variable...");
likecmd("SUUID_LOGDIR=$Outdir $CMD", # {{{
    "/^$v1_templ\n\$/s",
    '/^$/',
    "Read environment variable",
);

# }}}
like(file_data($Outfile), # {{{
    '/^' . join(' ',
        "<suuid t=\"$date_templ\" u=\"$v1_templ\">",
            "<cwd>.+?<\\/cwd>",
            "<user>.+<\\/user>",
            "<tty>.+<\\/tty>",
        "<\\/suuid>",
    ) . '\n$/s',
    "The environment variable was read",
);

# }}}
unlink($Outfile) || warn("$progname: $Outfile: Cannot delete file: $!\n");
diag("Testing -m (--random-mac) option...");
likecmd("$CMD -m -l $Outdir", # {{{
    "/^$v1rand_templ\\n\$/s",
    '/^$/s',
    "--random-mac option works",
);

# }}}
like(file_data($Outfile), # {{{
    '/^' . join(' ',
        "<suuid t=\"$date_templ\" u=\"$v1rand_templ\">",
            "<cwd>.+?<\\/cwd>",
            "<user>.+<\\/user>",
            "<tty>.+<\\/tty>",
        "<\\/suuid>",
    ) . '\n$/s',
    "Log contents OK after --random-mac",
);

# }}}
unlink($Outfile) || warn("$progname: $Outfile: Cannot delete file: $!\n");
diag("Testing --raw option...");
likecmd("$CMD --raw -c '<dingle><dangle>bær</dangle></dingle>' -l $Outdir", # {{{
    "/^$v1_templ\\n\$/s",
    '/^$/s',
    "--raw option works",
);

# }}}
like(file_data($Outfile), # {{{
    '/^' . join(' ',
        "<suuid t=\"$date_templ\" u=\"$v1_templ\">",
            "<txt><dingle><dangle>bær<\\/dangle><\\/dingle><\\/txt>",
            "<cwd>.+?<\\/cwd>",
            "<user>.+<\\/user>",
            "<tty>.+<\\/tty>",
        "<\\/suuid>",
    ) . '\n$/s',
    "Log contents after --raw is OK",
);

# }}}
unlink($Outfile) || warn("$progname: $Outfile: Cannot delete file: $!\n");
diag("Testing -t (--tag) option...");
likecmd("$CMD -t snaddertag -l $Outdir", # {{{
    "/^$v1_templ\n\$/s",
    '/^$/',
    "-t (--tag) option",
);

# }}}
like(file_data($Outfile), # {{{
    '/^' . join(' ',
        "<suuid t=\"$date_templ\" u=\"$v1_templ\">",
            "<tag>snaddertag<\\/tag>",
            "<cwd>.+?<\\/cwd>",
            "<user>.+<\\/user>",
            "<tty>.+<\\/tty>",
        "<\\/suuid>",
    ) . '\n$/s',
    "Log contents OK after tag",
);

# }}}
unlink($Outfile) || warn("$progname: $Outfile: Cannot delete file: $!\n");
diag("Testing -c (--comment) option...");
likecmd("$CMD -c \"Great test\" -l $Outdir", # {{{
    "/^$v1_templ\n\$/s",
    '/^$/',
    "-c (--comment) option",
);

# }}}
like(file_data($Outfile), # {{{
    '/^' . join(' ',
        "<suuid t=\"$date_templ\" u=\"$v1_templ\">",
            "<txt>Great test<\\/txt>",
            "<cwd>.+?<\\/cwd>",
            "<user>.+<\\/user>",
            "<tty>.+<\\/tty>",
        "<\\/suuid>",
    ) . '\n$/s',
    "Log contents OK after comment",
);

# }}}
unlink($Outfile) || warn("$progname: $Outfile: Cannot delete file: $!\n");
diag("Testing -n (--count) option...");
likecmd("$CMD -n 5 -c \"Great test\" -t testeri -l $Outdir", # {{{
    "/^($v1_templ\n){5}\$/s",
    '/^$/',
    "-n (--count) option with comment and tag",
);

# }}}
like(file_data($Outfile), # {{{
    '/^(' . join(' ',
        "<suuid t=\"$date_templ\" u=\"$v1_templ\">",
            "<tag>testeri<\\/tag>",
            "<txt>Great test<\\/txt>",
            "<cwd>.+?<\\/cwd>",
            "<user>.+<\\/user>",
            "<tty>.+<\\/tty>",
        "<\\/suuid>",
    ) . '\n){5}$/s',
    "Log contents OK after count, comment and tag",
);

# }}}
diag("Testing -v (--version) option...");
diag("Testing -w (--whereto) option...");
likecmd("$CMD -w o -l $Outdir", # {{{
    "/^$v1_templ\\n\$/s",
    '/^$/s',
    "Output goes to stdout",
);

# }}}
likecmd("$CMD -w e -l $Outdir", # {{{
    '/^$/s',
    "/^$v1_templ\\n\$/s",
    "Output goes to stderr",
);

# }}}
likecmd("$CMD -w eo -l $Outdir", # {{{
    "/^$v1_templ\\n\$/s",
    "/^$v1_templ\\n\$/s",
    "Output goes to stdout and stderr",
);

# }}}
likecmd("$CMD -w n -l $Outdir", # {{{
    '/^$/s',
    '/^$/s',
    "Output goes nowhere",
);

# }}}
diag("Testing -q (--quiet) option...");
diag("Test logging of \$SESS_UUID environment variable...");
unlink($Outfile) || warn("$progname: $Outfile: Cannot delete file: $!\n");
likecmd("SESS_UUID=27538da4-fc68-11dd-996d-000475e441b9 $CMD -t yess -l $Outdir", # {{{
    "/^$v1_templ\n\$/s",
    '/^$/',
    "-t (--tag) option",
);

# }}}
like(file_data($Outfile), # {{{
    '/^' . join(' ',
        "<suuid t=\"$date_templ\" u=\"$v1_templ\">",
            "<tag>yess<\\/tag>",
            "<cwd>.+?<\\/cwd>",
            "<user>.+<\\/user>",
            "<tty>.+<\\/tty>",
            "<sess>27538da4-fc68-11dd-996d-000475e441b9<\\/sess>",
        "<\\/suuid>",
    ) . '\n$/s',
    "\$SESS_UUID envariable is logged",
);

# }}}
diag("Test behaviour when unable to write to the log file...");
my @stat_array = stat($Outfile);
chmod(0444, $Outfile); # Make the log file read-only
likecmd("$CMD -l $Outdir", # {{{
    '/^$/s',
    "/^$cmdprogname: $Outfile: Cannot open file for append: .*\$/s",
    "Unable to write to the log file",
);
chmod($stat_array[2], $Outfile);

# }}}
todo_section:
;

if ($Opt{'all'} || $Opt{'todo'}) {
    diag("Running TODO tests..."); # {{{

    TODO: {

local $TODO = "";
# Insert TODO tests here.

    }
    # TODO tests }}}
}

diag("Testing finished.");

if (defined($Outfile)) {
    unlink($Outfile) || warn("$progname: $Outfile: Cannot delete file: $!\n");
}
rmdir($Outdir) || warn("$progname: $Outdir: Cannot remove directory: $!\n");

sub testcmd {
    # {{{
    my ($Cmd, $Exp_stdout, $Exp_stderr, $Desc) = @_;
    my $stderr_cmd = "";
    my $deb_str = $Opt{'debug'} ? " --debug" : "";
    my $Txt = join("",
        "\"$Cmd\"",
        defined($Desc)
            ? " - $Desc"
            : ""
    );
    $Txt =~ s/((-l |SUUID_LOGDIR=)tmp-suuid-t-)\d+-\d+/$1.../g;
    my $TMP_STDERR = "suuid-stderr.tmp";

    if (defined($Exp_stderr) && !length($deb_str)) {
        $stderr_cmd = " 2>$TMP_STDERR";
    }
    is(`$Cmd$deb_str$stderr_cmd`, $Exp_stdout, $Txt);
    if (defined($Exp_stderr)) {
        if (!length($deb_str)) {
            is(file_data($TMP_STDERR), $Exp_stderr, "$Txt (stderr)");
            unlink($TMP_STDERR);
        }
    } else {
        diag("Warning: stderr not defined for '$Txt'");
    }
    # }}}
}

sub likecmd {
    # {{{
    my ($Cmd, $Exp_stdout, $Exp_stderr, $Desc) = @_;
    my $stderr_cmd = "";
    my $deb_str = $Opt{'debug'} ? " --debug" : "";
    my $Txt = join("",
        "\"$Cmd\"",
        defined($Desc)
            ? " - $Desc"
            : ""
    );
    $Txt =~ s/((-l |SUUID_LOGDIR=)tmp-suuid-t-)\d+-\d+/$1.../g;
    my $TMP_STDERR = "suuid-stderr.tmp";

    if (defined($Exp_stderr) && !length($deb_str)) {
        $stderr_cmd = " 2>$TMP_STDERR";
    }
    like(`$Cmd$deb_str$stderr_cmd`, "$Exp_stdout", $Txt);
    if (defined($Exp_stderr)) {
        if (!length($deb_str)) {
            like(file_data($TMP_STDERR), "$Exp_stderr", "$Txt (stderr)");
            unlink($TMP_STDERR);
        }
    } else {
        diag("Warning: stderr not defined for '$Txt'");
    }
    # }}}
}

sub file_data {
    # Return file content as a string {{{
    my $File = shift;
    my $Txt;
    if (open(FP, "<", $File)) {
        $Txt = join("", <FP>);
        close(FP);
        return($Txt);
    } else {
        return undef;
    }
    # }}}
}

sub print_version {
    # Print program version {{{
    for (@main::version_array) {
        print("$_\n");
    }
    # }}}
} # print_version()

sub usage {
    # Send the help message to stdout {{{
    my $Retval = shift;

    if ($Opt{'verbose'}) {
        print("\n");
        print_version();
    }
    print(<<END);

Usage: $progname [options] [file [files [...]]]

Contains tests for the suuid(1) program.

Options:

  -a, --all
    Run all tests, also TODOs.
  -h, --help
    Show this help.
  -t, --todo
    Run only the TODO tests.
  -v, --verbose
    Increase level of verbosity. Can be repeated.
  --version
    Print version information.
  --debug
    Print debugging messages.

END
    exit($Retval);
    # }}}
} # usage()

sub msg {
    # Print a status message to stderr based on verbosity level {{{
    my ($verbose_level, $Txt) = @_;

    if ($Opt{'verbose'} >= $verbose_level) {
        print(STDERR "$progname: $Txt\n");
    }
    # }}}
} # msg()

__END__

# Plain Old Documentation (POD) {{{

=pod

=head1 NAME

run-tests.pl

=head1 REVISION

$Id$

=head1 SYNOPSIS

suuid.t [options] [file [files [...]]]

=head1 DESCRIPTION

Contains tests for the suuid(1) program.

=head1 OPTIONS

=over 4

=item B<-a>, B<--all>

Run all tests, also TODOs.

=item B<-h>, B<--help>

Print a brief help summary.

=item B<-t>, B<--todo>

Run only the TODO tests.

=item B<-v>, B<--verbose>

Increase level of verbosity. Can be repeated.

=item B<--version>

Print version information.

=item B<--debug>

Print debugging messages.

=back

=head1 AUTHOR

Made by Øyvind A. Holm S<E<lt>sunny@sunbase.orgE<gt>>.

=head1 COPYRIGHT

Copyleft © Øyvind A. Holm E<lt>sunny@sunbase.orgE<gt>
This is free software; see the file F<COPYING> for legalese stuff.

=head1 LICENCE

This program is free software; you can redistribute it and/or modify it 
under the terms of the GNU General Public License as published by the 
Free Software Foundation; either version 2 of the License, or (at your 
option) any later version.

This program is distributed in the hope that it will be useful, but 
WITHOUT ANY WARRANTY; without even the implied warranty of 
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
See the GNU General Public License for more details.

You should have received a copy of the GNU General Public License along 
with this program; if not, write to the Free Software Foundation, Inc., 
59 Temple Place, Suite 330, Boston, MA  02111-1307  USA

=head1 SEE ALSO

=cut

# }}}

# vim: set fenc=UTF-8 ft=perl fdm=marker ts=4 sw=4 sts=4 et fo+=w :
# End of file $Id$
