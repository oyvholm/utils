#!/usr/bin/perl -w

#=======================================================================
# $Id$
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

diag(sprintf("========== Executing \"%s%s%s\" ==========",
    $progname,
    scalar(@cmdline_array) ? " " : "",
    join(" ", @cmdline_array)));

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

my $Outdir = "tmp-suuid-t-$$-" . substr(rand, 2, 8);
if (-e $Outdir) {
    die("$progname: $Outdir: WTF?? Directory element already exists.");
}
unless (mkdir($Outdir)) {
    die("$progname: $Outdir: Cannot mkdir(): $!\n");
}

diag("Testing -h (--help) option...");
likecmd("$CMD -h", # {{{
    '/  Show this help\./',
    '/^$/',
    "Option -h prints help screen",
);

# }}}
unlike(`$CMD -h`, # {{{
    '/\$Id: /',
    "\"$CMD -h\" - No Id with only -h",
);

# }}}
diag("Testing --verbose option...");
likecmd("$CMD -h --verbose", # {{{
    '/\$Id: .*? \$.*  Show this help\./s',
    '/^$/',
    "Option --verbose with -h returns Id string and help screen",
);

# }}}
diag("Testing --show-version option...");
likecmd("$CMD --show-version", # {{{
    '/\$Id: .*? \$/',
    '/^$/',
    "Option --show-version returns Id string",
);

# }}}
my $Lh = "[0-9a-f]";
my $Templ = "$Lh\{8}-$Lh\{4}-$Lh\{4}-$Lh\{4}-$Lh\{12}";
my $v1_templ = "$Lh\{8}-$Lh\{4}-1$Lh\{3}-$Lh\{4}-$Lh\{12}";
my $v4_templ = "$Lh\{8}-$Lh\{4}-4$Lh\{3}-$Lh\{4}-$Lh\{12}";
my $date_templ = "20[0-9][0-9]-[0-1][0-9]-[0-3][0-9]T[0-2][0-9]:[0-5][0-9]:[0-6][0-9]Z";
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
    '/^' . join('\t',
        '3',
        $v1_templ, # uuid
        $date_templ, # date
        '', # tag
        '', # comment
        '.+?', # hostname:dir
        '.+' # username
    ) . '\n$/s',
    "Log contents OK after exec with no options",
);

# }}}
system("$CMD -l $Outdir >/dev/null");
like(file_data($Outfile), # {{{
    '/^(' . join('\t',
        '3',
        $v1_templ, # uuid
        $date_templ, # date
        '', # tag
        '', # comment
        '.+?', # hostname:dir
        '.+' # username
    ) . '\n){2}$/s',
    "Entries are added, not replacing",
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
    '/^' . join('\t',
        '3',
        $v1_templ, # uuid
        $date_templ, # date
        'snaddertag', # tag
        '', # comment
        '.+?', # hostname:dir
        '.+' # username
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
like(`tail -1 $Outfile`, # {{{
    '/^' . join('\t',
        '3',
        $v1_templ, # uuid
        $date_templ, # date
        '', # tag
        'Great test', # comment
        '.+?', # hostname:dir
        '.+' # username
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
    '/^(' . join('\t',
        '3',
        $v1_templ, # uuid
        $date_templ, # date
        'testeri', # tag
        'Great test', # comment
        '.+?', # hostname:dir
        '.+' # username
    ) . '\n){5}$/s',
    "Log contents OK after count, comment and tag",
);

# }}}
diag("Testing -v (--version) option...");
diag("Testing -q (--quiet) option...");
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

unlink($Outfile) || warn("$progname: $Outfile: Cannot delete file: $!\n");
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
    $Txt =~ s/(-l tmp-suuid-t-)\d+-\d+/$1.../g;
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
    $Txt =~ s/(-l tmp-suuid-t-)\d+-\d+/$1.../g;
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
