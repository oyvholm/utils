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

    my $Lh = "[0-9a-fA-F]";
    my $Templ = "$Lh\{8}-$Lh\{4}-$Lh\{4}-$Lh\{4}-$Lh\{12}";
    my $v1_templ = "$Lh\{8}-$Lh\{4}-1$Lh\{3}-$Lh\{4}-$Lh\{12}";
    my $v1rand_templ = "$Lh\{8}-$Lh\{4}-1$Lh\{3}-$Lh\{4}-$Lh\[37bf]$Lh\{10}";
    my $v4_templ = "$Lh\{8}-$Lh\{4}-4$Lh\{3}-[89ab]$Lh\{3}-$Lh\{12}";

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

    diag("Checking coreutils...");
    coreutils(qw{
        arch base64 basename cat chcon chgrp chmod chown chroot cksum 
        comm cp csplit cut date dd df dir dircolors dirname du echo env 
        expand expr factor false fmt fold groups head hostid id install 
        join link ln logname ls md5sum mkdir mkfifo mknod mktemp mv nice 
        nl nohup nproc od paste pathchk pinky pr printenv printf ptx pwd 
        readlink rm rmdir runcon seq sha1sum sha224sum sha256sum 
        sha384sum sha512sum shred sleep sort split stat stty sum sync 
        tac tail tee timeout touch tr true truncate tsort tty uname 
        unexpand uniq unlink users vdir wc who whoami yes
    });

    diag("Checking important software...");
    installed('autoconf --version', '/GNU Autoconf/');
    installed('bash --version', '/^GNU bash/');
    installed('bc --version', '/^bc \d.*Free Software Foundation/s');
    installed('curl --version', '/^curl /');
    installed('echo ABC ZZZ aabel abbel abc bbbe © Å Æ Ø å æ ø → | fmt -1 | sort', '/^ABC\nZZZ\naabel\nabbel\nabc\nbbbe\n©\nÅ\nÆ\nØ\nå\næ\nø\n→\n$/', 'Use C sorting order');
    installed('find --version', '/GNU findutils/');
    installed('gcc --version', '/^gcc /');
    installed('git --version', '/git version/');
    installed('git-annex version', '/^git-annex version: /');
    installed('gpg --version', '/^gpg.+GnuPG\b/');
    installed('grep --version', '/GNU grep/');
    installed('gzip --version', '/^gzip \d/');
    installed('make --version', '/GNU Make/');
    installed('mc --version', '/GNU Midnight Commander/');
    installed('perl --version', '/This is perl( |, v)5/');
    installed('python --version', '/Python (2|3)/');
    installed('rsync --version', '/^rsync\s+version \d/');
    installed('screen --version', '/^Screen version \d/');
    installed('script --version', '/^script .+\butil-linux\b/');
    installed('ssh -V', '/OpenSSH/');
    installed('tar --version', '/GNU tar\b/');
    installed('top -v', '/procps(-ng)? version \d/');
    installed('vim --version', '/VIM - Vi IMproved 7\../');
    installed('wget --version', '/GNU Wget/');
    repeat_test('uuidgen -r', 100, "^$v4_templ\$");
    repeat_test('uuidgen -t', 100, "^$v1_templ\$");

    if ($Opt{'all'}) {

        diag("Checking other software...");
        installed('abiword --version', '/^\d\.\d+\.\d+/');
        installed('arj', '/^ARJ\S*? v \d/');
        installed('asciidoc --version', '/^asciidoc \d/');
        installed('bash -c "type -p gnome-system-monitor"', '/bin\/gnome-system-monitor$/');
        installed('cdparanoia --version', '/^cdparanoia III/');
        installed('celestia --help', '/Usage:.*\bcelestia\b.+OPTION/s');
        installed('cpio --version', '/GNU cpio/');
        installed('cronolog --version', '/^cronolog version \d/');
        installed('ctags --version', '/^(Exuberant Ctags|ctags \(GNU Emacs) \d/');
        installed('dict --version', '/^dict \d/');
        installed('dot -V', '/graphviz version \d/');
        installed('echo "[{ }]" | json_reformat -m', '/^\[{}+]$/', 'json_reformat');
        installed('exifprobe -V', '/Program: \'exifprobe\' version \d/');
        installed('exiftool -ver', '/^\d+\.\d/');
        installed('fdupes --version', '/^fdupes \d\./');
        installed('flac --version', '/^flac /');
        installed('geeqie --version', '/^Geeqie \d\./');
        installed('gettext --version', '/GNU gettext/');
        installed('gnucash --version', '/GnuCash \d\./');
        installed('gnumeric --version', '/^gnumeric version /');
        installed('gnuplot --version', '/^gnuplot /');
        installed('gource --help', '/Gource v\d/');
        installed('gpsbabel --version', '/GPSBabel Version \d/');
        installed('htop --version', '/^htop \d/');
        installed('inkscape -V', '/^Inkscape \d/');
        installed('iotop --version', '/^iotop \d/');
        installed('lame --version', '/LAME .* version /');
        installed('lftp --version', '/^LFTP .+Version \d/');
        installed('lynx --version', '/^Lynx Version \d/');
        installed('mosh --version', '/^mosh \d/');
        installed('mplayer -V', '/^MPlayer2 /');
        installed('mutt -h', '/^Mutt \d/');
        installed('ncdu -v', '/^ncdu \d/');
        installed('ncftp -v', '/Program version:\s+NcFTP /');
        installed('nmap --version', '/Nmap version /');
        installed('okular --version', '/Okular: \d/');
        installed('pandoc --version', '/^pandoc \d\./');
        installed('pinfo --version', '/^Przemek\'s Info Viewer /');
        installed('psql --version', '/psql \(PostgreSQL\)/');
        installed('pv --version', '/^pv \d/');
        installed('pylint --version', '/^pylint \d/');
        installed('qemu-system-i386 --version', '/QEMU emulator version \d/');
        installed('recode --version', '/^Free recode \d/');
        installed('rtorrent -h', '/BitTorrent client version /');
        installed('sqlite3 --version', '/^\d\.\d/');
        installed('sshfs --version', '/SSHFS version \d/');
        installed('strace -V', '/^strace -- version \d/');
        installed('svn --version', '/svn, version /');
        installed('tig --version', '/^tig version /');
        installed('tmux -V', '/^tmux \d\./');
        installed('tree --version', '/^tree v\d\./');
        installed('ufraw --version', '/^ufraw \d/');
        installed('unrar --version', '/UNRAR \d/');
        installed('unzip -v', '/^UnZip \d.*Info-ZIP/');
        installed('uprecords -v', '/^uprecords \d/');
        installed('uuid -d ac89d100-5809-11e0-b3ff-00023faf1383', '/2011-03-27 00:32:19\.377792\.0 UTC/', 'OSSP uuid');
        installed('vlc --version', '/^VLC version \d/');
        installed('whois --version', '/^Version \d/');
        installed('wireshark --version', '/^wireshark \d/');
        installed('x264 --version', '/^x264 \d/');
        installed('xdot --help', '/Usage:.*\bxdot\b/s');
        installed('xmllint --version', '/^xmllint: using libxml version /');
        installed('xmlto --version', '/^xmlto version \d/');
        installed('xtightvncviewer -h', '/^TightVNC Viewer /');
        installed('youtube-dl --version', '/^20\d\d\.\d\d\.\d\d/');
        installed('zip -v', '/This is Zip \d.*Info-ZIP/');

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

sub coreutils {
    # {{{
    my @progs = @_;
    my $retval = 0;
    for my $curr (@progs) {
        installed("$curr --version", "/^$curr .*?\\bcoreutils\\b/") || ($retval = 1);
    }
    return($retval);
    # }}}
} # coreutils()

sub repeat_test {
    # {{{
    my ($cmd, $count, $regexp) = @_;
    my $retval = 0;
    my $erruuid = '';

    for (my $t = $count; $t && ($retval < 10); $t--) {
        my $uuid = `$cmd`;
        $uuid =~ /$regexp/s || ($retval++, $erruuid .= $uuid);
    }

    is($erruuid, '', "$cmd: Repeat test $count times");
    return($retval);
    # }}}
} # repeat_test()

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
