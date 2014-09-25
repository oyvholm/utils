#!/usr/bin/perl

#=======================================================================
# installed_progs.t
# File ID: 3d0e23bc-400e-11e4-a184-c80aa9e67bbd
# Check that some necessary programs are installed.
#
# Character set: UTF-8
# ©opyleft 2014– Øyvind A. Holm <sunny@sunbase.org>
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
our $CMD = '';

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

exit(main(%Opt));

sub main {
    # {{{
    my %Opt = @_;
    my $Retval = 0;

    diag(sprintf('========== Executing %s v%s ==========',
        $progname,
        $VERSION));

    if ($Opt{'todo'} && !$Opt{'all'}) {
        goto todo_section;
    }

=pod

    installed('prog --version', # {{{
        '//',
        'description',
    );

    # }}}

=cut

    installed('autoconf --version', '/GNU Autoconf/');
    installed('curl --version', '/^curl /');
    installed('echo ABC ZZZ aabel abbel abc bbbe © Å Æ Ø å æ ø → | fmt -1 | sort', '/^ABC\nZZZ\naabel\nabbel\nabc\nbbbe\n©\nÅ\nÆ\nØ\nå\næ\nø\n→\n$/', 'Use C sorting order');
    installed('gcc --version', '/^gcc /');
    installed('git --version', '/git version/');
    installed('make --version', '/GNU Make/');
    installed('mc --version', '/GNU Midnight Commander/');
    installed('perl --version', '/This is perl( |, v)5/');
    installed('python --version', '/Python (2|3)/');
    installed('ssh -V', '/OpenSSH/');
    installed('uuidgen --version', '/uuidgen from util-linux/');
    installed('vim --version', '/VIM - Vi IMproved 7\../');
    installed('wget --version', '/GNU Wget/');

    if ($Opt{'all'}) {

        installed('abiword --version', '/^\d\.\d+\.\d+/');
        installed('colordiff --version', '/GNU diffutils/');
        installed('cronolog --version', '/^cronolog version \d/');
        installed('ctags --version', '/^Exuberant Ctags \d/');
        installed('dict --version', '/^dict \d/');
        installed('dot -V', '/graphviz version \d/');
        installed('echo "[{ }]" | json_reformat -m', '/^\[{}+]$/', 'json_reformat');
        installed('exifprobe -V', '/Program: \'exifprobe\' version \d/');
        installed('fdupes --version', '/^fdupes \d\./');
        installed('flac --version', '/^flac /', 'FLAC');
        installed('geeqie --version', '/^Geeqie \d\./');
        installed('gettext --version', '/GNU gettext/');
        installed('gnucash --version', '/GnuCash \d\./');
        installed('gnumeric --version', '/^gnumeric version /');
        installed('gnuplot --version', '/^gnuplot /');
        installed('gource --help', '/Gource v\d/');
        installed('gpsbabel --version', '/GPSBabel Version \d/');
        installed('lame --version', '/LAME .* version /');
        installed('mosh --version', '/^mosh \d/');
        installed('mplayer -V', '/^MPlayer2 /');
        installed('ncdu -v', '/^ncdu \d/');
        installed('nmap --version', '/Nmap version /');
        installed('pandoc --version', '/^pandoc \d\./');
        installed('psql --version', '/psql \(PostgreSQL\)/');
        installed('pv --version', '/^pv \d/');
        installed('qemu-system-i386 --version', '/QEMU emulator version \d/');
        installed('rtorrent -h', '/BitTorrent client version /');
        installed('sqlite3 --version', '/^\d\.\d/');
        installed('sshfs --version', '/SSHFS version \d/');
        installed('strace -V', '/^strace -- version \d/');
        installed('svn --version', '/svn, version /');
        installed('tig --version', '/^tig version /');
        installed('tmux -V', '/^tmux \d\./');
        installed('tree --version', '/^tree v\d\./');
        installed('uprecords -v', '/^uprecords \d/');
        installed('vlc --version', '/^VLC version \d/');
        installed('whois --version', '/^Version \d/');
        installed('xmlto --version', '/^xmlto version \d/');

    }

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

    diag('Testing finished.');
    # }}}
} # main()

sub installed {
    # {{{
    my ($Cmd, $Exp, $Desc) = @_;
    my $stderr_cmd = '';
    my $Txt = join('',
        "\"$Cmd\"",
        defined($Desc)
            ? " - $Desc"
            : ''
    );

    like(`$Cmd 2>&1`, $Exp, $Txt);
    return;
    # }}}
} # installed()

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
    my $TMP_STDERR = 'installed_progs-stderr.tmp';

    if (defined($Exp_stderr) && !length($deb_str)) {
        $stderr_cmd = " 2>$TMP_STDERR";
    }
    is(`$Cmd$deb_str$stderr_cmd`, "$Exp_stdout", "$Txt (stdout)");
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
    my $TMP_STDERR = 'installed_progs-stderr.tmp';

    if (defined($Exp_stderr) && !length($deb_str)) {
        $stderr_cmd = " 2>$TMP_STDERR";
    }
    like(`$Cmd$deb_str$stderr_cmd`, "$Exp_stdout", "$Txt (stdout)");
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

Check for missing necessary programs needed by some scripts.

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

installed_progs.t [options] [file [files [...]]]

=head1 DESCRIPTION



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
