#!/usr/bin/perl

#=======================================================================
# std.t
# File ID: 685626fa-f988-11dd-af37-000475e441b9
# Test suite for std(1).
#
# Character set: UTF-8
# ©opyleft 2008– Øyvind A. Holm <sunny@sunbase.org>
# License: GNU General Public License version 3 or later, see end of 
# file for legal stuff.
#=======================================================================

use strict;
use warnings;

BEGIN {
    # push(@INC, "$ENV{'HOME'}/bin/STDlibdirDTS");
    use Test::More qw{no_plan};
    # use_ok() goes here
}

use Getopt::Long;

local $| = 1;

our $Debug = 0;
our $CMD = '../std';
my $Lh = "[0-9a-fA-F]";
my $v1_templ = "$Lh\{8}-$Lh\{4}-1$Lh\{3}-$Lh\{4}-$Lh\{12}";
my $use_svn = 0;

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
our $VERSION = '0.00';

Getopt::Long::Configure('bundling');
GetOptions(

    'all|a' => \$Opt{'all'},
    'debug' => \$Opt{'debug'},
    'help|h' => \$Opt{'help'},
    'todo|t' => \$Opt{'todo'},
    'verbose|v+' => \$Opt{'verbose'},
    'version' => \$Opt{'version'},

) || die("$progname: Option error. Use -h for help.\n");

$Opt{'debug'} && ($Debug = 1);
$Opt{'help'} && usage(0);
if ($Opt{'version'}) {
    print_version();
    exit(0);
}

diag(sprintf('========== Executing %s v%s ==========',
    $progname,
    $VERSION));

if ($Opt{'todo'} && !$Opt{'all'}) {
    goto todo_section;
}

=pod

testcmd("$CMD command", # {{{
    <<'END',
[expected stdin]
END
    '',
    0,
    'description',
);

# }}}

=cut

diag('Testing -h (--help) option...');
likecmd("$CMD -h", # {{{
    '/  Show this help\./',
    '/^$/',
    0,
    'Option -h prints help screen',
);

# }}}
diag('Testing -v (--verbose) option...');
likecmd("$CMD -hv", # {{{
    '/^\n\S+ v\d\.\d\d\n/s',
    '/^$/',
    0,
    'Option --version with -h returns version number and help screen',
);

# }}}
diag('Testing --version option...');
likecmd("$CMD --version", # {{{
    '/^\S+ v\d\.\d\d\n/',
    '/^$/',
    0,
    'Option --version returns version number',
);

# }}}

my $Tmptop = "tmp-std-t-$$-" . substr(rand, 2, 8);
diag("Creating tempdir...");
if ($use_svn) {
    likecmd("svn mkdir $Tmptop", # {{{
        '/^A\s+tmp-std-t-.+$/s',
        '/^$/s',
        0,
        "Create svn-controlled directory",
    );
    # }}}
} else {
    mkdir($Tmptop) || die("$progname: $Tmptop: Cannot create directory: $!\n");
}
chdir($Tmptop) || die("$progname: $Tmptop: Cannot chdir(): $!");
mkdir("tmpuuids") || die("$progname: $Tmptop/tmpuuids: Cannot mkdir(): $!");
likecmd("SUUID_LOGDIR=tmpuuids ../$CMD bash", # {{{
    '/GNU General Public License/s',
    '/^std: Warning: Undefined tags: filename\n$/s',
    0,
    "One argument sends file to stdout",
);

# }}}
my $suuid_file = glob("tmpuuids/*");
ok(-e $suuid_file, "suuid log file exists");
if ($use_svn) {
    likecmd("SUUID_LOGDIR=tmpuuids ../$CMD bash bashfile", # {{{
        "/^$v1_templ\\nA\\s+bashfile.+\$/s",
        '/^mergesvn: bashfile: Using revision \d+ instead of HEAD\n$/s',
        0,
        "Create bash script",
    );
    # }}}
} else {
    likecmd("SUUID_LOGDIR=tmpuuids ../$CMD bash bashfile", # {{{
        "/^$v1_templ\\n\$/s",
        '/^$/',
        0,
        "Create bash script",
    );
    # }}}
}
ok(-e "bashfile", "bashfile exists");
ok(unlink('bashfile'), 'Remove bashfile');
likecmd("SUUID_LOGDIR=tmpuuids ../$CMD -l bash bashfile", # {{{
    "/^$v1_templ\\n\$/s",
    '/^$/',
    0,
    "Create bash script with -l (--local)",
);

# }}}
ok(-x "bashfile", "bashfile is executable");
$use_svn && likecmd("svn propget mergesvn bashfile", # {{{
    '/^\d+ \S+Lib\/std\/bash\n$/s',
    '/^$/s',
    0,
    "mergesvn property is set to bash template",
);

# }}}
diag("Check for unused tags...");
likecmd("SUUID_LOGDIR=tmpuuids ../$CMD perl-tests", # {{{
    '/^.*Contains tests for the.*$/s',
    '/^std: Warning: Undefined tags: testcmd filename progname exec libdir\n$/s',
    0,
    "Report unused tags",
);

# }}}
diag("Testing -f (--force) option...");
likecmd("../$CMD bash bashfile", # {{{
    '/^$/s',
    '/^std: bashfile: File already exists, will not overwrite\n$/s',
    9,
    "Create bash script, file already exists, don’t use --force",
);

# }}}
if ($use_svn) {
    likecmd("LC_ALL=C SUUID_LOGDIR=tmpuuids ../$CMD -fv perl bashfile", # {{{
        "/^$v1_templ\\nproperty \'mergesvn\' set on \'bashfile\'\\n/s",
        '/^std: Overwriting \'bashfile\'\.\.\.\n/s',
        0,
        "Overwrite bashfile with perl script using --force",
    );
    # }}}
} else {
    likecmd("LC_ALL=C SUUID_LOGDIR=tmpuuids ../$CMD -fv perl bashfile", # {{{
        "/^$v1_templ\\n\$/s",
        '/^std: Overwriting \'bashfile\'\.\.\.\n/s',
        0,
        "Overwrite bashfile with perl script using --force",
    );
    # }}}
}
like(file_data("bashfile"), # {{{
    qr/use Getopt::Long/s,
    "Contents of bashfile is replaced"
);

# }}}
$use_svn && likecmd("svn propget mergesvn bashfile", # {{{
    '/^\d+ \S+Lib\/std\/perl\n$/s',
    '/^$/s',
    0,
    "mergesvn property is replaced with perl template",
);

# }}}
diag("Testing -T (--notag) option...");
likecmd("SUUID_LOGDIR=tmpuuids ../$CMD -T uuid,year perl", # {{{
    '/STDuuidDTS.*STDyearDTS/s',
    '/^std: Warning: Undefined tags: filename uuid year\n.*$/s',
    0,
    "Send perl script to stdout, don’t expand uuid and year tag",
);

# }}}

todo_section:
;

if ($Opt{'all'} || $Opt{'todo'}) {
    diag('Running TODO tests...'); # {{{

    TODO: {

local $TODO = '';
# Insert TODO tests here.

    }
    # TODO tests }}}
}

chdir("..") || die("$progname: Cannot 'chdir ..': $!");
diag("Cleaning up temp files...");
$use_svn && likecmd("svn revert $Tmptop", # {{{
    '/tmp-std-t/s',
    '/^$/s',
    0,
    "svn revert tempdir",
);

# }}}
ok(unlink(glob "$Tmptop/tmpuuids/*"), "unlink('glob $Tmptop/tmpuuids/*')");
ok(rmdir("$Tmptop/tmpuuids"), "rmdir('$Tmptop/tmpuuids')");
ok(unlink("$Tmptop/bashfile"), "unlink('$Tmptop/bashfile')");
ok(rmdir($Tmptop), "rmdir('$Tmptop')");

diag('Testing finished.');

sub testcmd {
    # {{{
    my ($Cmd, $Exp_stdout, $Exp_stderr, $Exp_retval, $Desc) = @_;
    my $stderr_cmd = '';
    my $deb_str = $Opt{'debug'} ? ' --debug' : '';
    my $Txt = join('',
        "\"$Cmd\"",
        defined($Desc)
            ? " - $Desc"
            : ''
    );
    my $TMP_STDERR = 'std-stderr.tmp';

    if (defined($Exp_stderr) && !length($deb_str)) {
        $stderr_cmd = " 2>$TMP_STDERR";
    }
    is(`$Cmd$deb_str$stderr_cmd`, $Exp_stdout, $Txt);
    my $ret_val = $?;
    if (defined($Exp_stderr)) {
        if (!length($deb_str)) {
            is(file_data($TMP_STDERR), $Exp_stderr, "$Txt (stderr)");
            unlink($TMP_STDERR);
        }
    } else {
        diag("Warning: stderr not defined for '$Txt'");
    }
    is($ret_val >> 8, $Exp_retval, "$Txt (retval)");
    return;
    # }}}
} # testcmd()

sub likecmd {
    # {{{
    my ($Cmd, $Exp_stdout, $Exp_stderr, $Exp_retval, $Desc) = @_;
    my $stderr_cmd = '';
    my $deb_str = $Opt{'debug'} ? ' --debug' : '';
    my $Txt = join('',
        "\"$Cmd\"",
        defined($Desc)
            ? " - $Desc"
            : ''
    );
    my $TMP_STDERR = 'std-stderr.tmp';

    if (defined($Exp_stderr) && !length($deb_str)) {
        $stderr_cmd = " 2>$TMP_STDERR";
    }
    like(`$Cmd$deb_str$stderr_cmd`, "$Exp_stdout", $Txt);
    my $ret_val = $?;
    if (defined($Exp_stderr)) {
        if (!length($deb_str)) {
            like(file_data($TMP_STDERR), "$Exp_stderr", "$Txt (stderr)");
            unlink($TMP_STDERR);
        }
    } else {
        diag("Warning: stderr not defined for '$Txt'");
    }
    is($ret_val >> 8, $Exp_retval, "$Txt (retval)");
    return;
    # }}}
} # likecmd()

sub file_data {
    # Return file content as a string {{{
    my $File = shift;
    my $Txt;
    if (open(my $fp, '<', $File)) {
        local $/ = undef;
        $Txt = <$fp>;
        close($fp);
        return($Txt);
    } else {
        return;
    }
    # }}}
} # file_data()

sub print_version {
    # Print program version {{{
    print("$progname v$VERSION\n");
    return;
    # }}}
} # print_version()

sub usage {
    # Send the help message to stdout {{{
    my $Retval = shift;

    if ($Opt{'verbose'}) {
        print("\n");
        print_version();
    }
    print(<<"END");

Usage: $progname [options] [file [files [...]]]

Contains tests for the std(1) program.

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
    return;
    # }}}
} # msg()

__END__

# Plain Old Documentation (POD) {{{

=pod

=head1 NAME

run-tests.pl

=head1 SYNOPSIS

std.t [options] [file [files [...]]]

=head1 DESCRIPTION

Contains tests for the std(1) program.

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

This program is free software: you can redistribute it and/or modify it 
under the terms of the GNU General Public License as published by the 
Free Software Foundation, either version 3 of the License, or (at your 
option) any later version.

This program is distributed in the hope that it will be useful, but 
WITHOUT ANY WARRANTY; without even the implied warranty of 
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
See the GNU General Public License for more details.

You should have received a copy of the GNU General Public License along 
with this program.
If not, see L<http://www.gnu.org/licenses/>.

=head1 SEE ALSO

=cut

# }}}

# vim: set fenc=UTF-8 ft=perl fdm=marker ts=4 sw=4 sts=4 et fo+=w :
