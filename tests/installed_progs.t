#!/usr/bin/env perl

#=======================================================================
# installed_progs.t
# File ID: 3d0e23bc-400e-11e4-a184-c80aa9e67bbd
#
# Check that some necessary programs are installed.
#
# Character set: UTF-8
# ©opyleft 2014– Øyvind A. Holm <sunny@sunbase.org>
# License: GNU General Public License version 2 or later, see end of 
# file for legal stuff.
#=======================================================================

use strict;
use warnings;

use Test::More;
if ($^O ne "linux") {
    plan skip_all => "We're not on GNU/Linux";
} else {
    plan "no_plan";
}

use Getopt::Long;

local $| = 1;

our $CMD_BASENAME = "";
our $CMD = "../$CMD_BASENAME";

our %Opt = (

    'all' => 0,
    'gui' => 0,
    'help' => 0,
    'other' => 0,
    'quiet' => 0,
    'todo' => 0,
    'verbose' => 0,
    'version' => 0,

);

our $progname = $0;
$progname =~ s/^.*\/(.*?)$/$1/;
our $VERSION = '0.6.0';

my %descriptions = ();

Getopt::Long::Configure('bundling');
GetOptions(

    'all|a' => \$Opt{'all'},
    'gui|g' => \$Opt{'gui'},
    'help|h' => \$Opt{'help'},
    'other|o' => \$Opt{'other'},
    'quiet|q+' => \$Opt{'quiet'},
    'todo|t' => \$Opt{'todo'},
    'verbose|v+' => \$Opt{'verbose'},
    'version' => \$Opt{'version'},

) || die("$progname: Option error. Use -h for help.\n");

$Opt{'verbose'} -= $Opt{'quiet'};
$Opt{'help'} && usage(0);
if ($Opt{'version'}) {
    print_version();
    exit(0);
}

exit(main());

sub main {
    # {{{
    my $Retval = 0;

    my $Lh = "[0-9a-fA-F]";
    my $Templ = "$Lh\{8}-$Lh\{4}-$Lh\{4}-$Lh\{4}-$Lh\{12}";
    my $v1_templ = "$Lh\{8}-$Lh\{4}-1$Lh\{3}-$Lh\{4}-$Lh\{12}";
    my $v1rand_templ = "$Lh\{8}-$Lh\{4}-1$Lh\{3}-$Lh\{4}-$Lh\[37bf]$Lh\{10}";
    my $v4_templ = "$Lh\{8}-$Lh\{4}-4$Lh\{3}-[89ab]$Lh\{3}-$Lh\{12}";

    diag(sprintf('========== Executing %s v%s ==========',
                 $progname, $VERSION));

    if ($Opt{'todo'} && !$Opt{'all'}) {
        goto todo_section;
    }

=pod

    testcmd("$CMD command", # {{{
        <<'END',
[expected stdout]
END
        '',
        0,
        'description',
    );

    # }}}

=cut

    diag("Checking coreutils...");
    coreutils(qw{
        arch base32 base64 basename cat chcon chgrp chmod chown chroot 
        cksum comm cp csplit cut date dd df dir dircolors dirname du 
        echo env expand expr factor false fmt fold groups head hostid id 
        install join kill link ln logname ls md5sum mkdir mkfifo mknod 
        mktemp mv nice nl nohup nproc numfmt od paste pathchk pinky pr 
        printenv printf ptx pwd readlink realpath rm rmdir runcon seq 
        sha1sum sha224sum sha256sum sha384sum sha512sum shred shuf sleep 
        sort split stat stdbuf stty sum sync tac tail tee timeout touch 
        tr true truncate tsort tty uname unexpand uniq unlink uptime 
        users vdir wc who whoami yes
    });

    diag("Checking important software...");
    installed('archivemount --version', '/^archivemount version \d/', 'stderr');
    installed('autoconf --version', '/GNU Autoconf/', 'stdout');
    installed('bash --version', '/^GNU bash/', 'stdout');
    installed('bc --version', '/^bc \d.*Free Software Foundation/s', 'stdout');
    installed('cmake --version', '/^cmake version \d/', 'stdout');
    installed('cmark --version', '/^cmark \d+\.\d+\.\d+/', 'stdout');
    installed('cronolog --version', '/^cronolog version \d/', 'stderr');
    installed('ctags --version', '/^Exuberant Ctags \d/', 'stdout');
    installed('curl --version', '/^curl /', 'stdout');
    installed('dict --version', '/^dict \d/', 'stdout');
    installed('echo ABC ZZZ aabel abbel abc bbbe © Å Æ Ø å æ ø → 🤘 | fmt -1 | sort', '/^ABC\nZZZ\naabel\nabbel\nabc\nbbbe\n©\nÅ\nÆ\nØ\nå\næ\nø\n→\n🤘\n$/', 'stdout', 'Use C sorting order');
    installed('exifprobe -V', '/Program: \'exifprobe\' version \d/', 'stdout');
    installed('find --version', '/GNU findutils/', 'stdout');
    installed('fossil version', '/^This is fossil version 1\.36 /', 'stdout');
    installed('gadu --version', '/git-annex-utils \d/', 'stdout');
    installed('gcc --version', '/^gcc /', 'stdout');
    installed('git --version', '/^git version 2\.11/', 'stdout');
    installed('git-annex version', '/^git-annex version: /', 'stdout');
    installed('gnuplot --version', '/^gnuplot /', 'stdout');
    installed('gpg --version', '/^gpg.+GnuPG\b/', 'stdout');
    installed('grep --version', '/GNU grep/', 'stdout');
    installed('gzip --version', '/^gzip \d/', 'stdout');
    installed('lilypond --version', '/^GNU LilyPond 2/', 'stdout');
    installed('make --version', '/GNU Make/', 'stdout');
    installed('mc --version', '/GNU Midnight Commander/', 'stdout');
    installed('mysql --version', '/^$/', 'stdout', 'MySQL is not installed');
    installed('ncdu -v', '/^ncdu \d/', 'stdout');
    installed('perl --version', '/This is perl( |, v)5/', 'stdout');
    installed('pinfo --version', '/^Przemek\'s Info Viewer /', 'stdout');
    installed('pip --version', '/^pip \d/', 'stdout');
    installed('pv --version', '/^pv \d/', 'stdout');
    installed('pylint --version', '/^pylint \d/', 'stdout');
    installed('python --version', '/Python (2|3)/', 'stderr');
    installed('python3 --version', '/^Python 3/', 'both');
    installed('recode --version', '/^Free recode \d/', 'stdout');
    installed('rsync --version', '/^rsync\s+version \d/', 'stdout');
    installed('screen --version', '/^Screen version \d/', 'stdout');
    installed('script --version', '/^script .+\butil-linux\b/', 'stdout');
    installed('sqlite3 --version', '/^3\.16\.1 2017-01-03 18:27:03/', 'stdout');
    installed('ssh -V', '/OpenSSH/', 'stderr');
    installed('sshfs --version', '/SSHFS version \d/', 'stdout');
    installed('tar --version', '/GNU tar\b/', 'stdout');
    installed('task --version', '/^2\.5\.1$/', 'stdout');
    installed('top -v', '/procps(-ng)? version \d/', 'stdout');
    installed('tree --version', '/^tree v\d\./', 'stdout');
    installed('unzip -v', '/^UnZip \d.*Info-ZIP/', 'stdout');
    installed('uprecords -v', '/^uprecords \d/', 'stdout');
    installed('uuencode --version', '/^uuencode \(GNU sharutils\)/', 'stdout');
    installed('uuid -d ac89d100-5809-11e0-b3ff-00023faf1383', '/2011-03-27 00:32:19\.377792\.0 UTC/', 'stdout', 'OSSP uuid');
    installed('vim --version', '/VIM - Vi IMproved 8\../', 'stdout');
    installed('wget --version', '/GNU Wget/', 'stdout');
    installed('wiggle --version', '/^wiggle v1\.0/', 'stderr');
    installed('zip -v', '/This is Zip \d.*Info-ZIP/', 'stdout');
    repeat_test('uuidgen -r', 100, "^$v4_templ\$");
    repeat_test('uuidgen -t', 100, "^$v1_templ\$");

    is(`echo "SELECT json('[\\"a\\",   4,   true, { \\"abc\\"  :\\"def\\"}]');" | sqlite3 2>/dev/null`,
        "[\"a\",4,true,{\"abc\":\"def\"}]\n",
        "sqlite3 has json support",
    );

    if ($Opt{'other'} || $Opt{'all'}) {

        diag("Checking other software...");
        installed('arj', '/^ARJ\S*? v \d/', 'stdout');
        installed('asciidoc --version', '/^asciidoc \d/', 'stdout');
        installed('bison --version', '/^bison\b.+GNU Bison\b/', 'stdout');
        installed('cdparanoia --version', '/^cdparanoia III/', 'stderr');
        installed('cpio --version', '/GNU cpio/', 'stdout');
        installed('dblatex --version', '/^dblatex version \d/', 'stdout');
        installed('dot -V', '/graphviz version \d/', 'stderr');
        installed('echo "[{ }]" | json_reformat -m', '/^\[{}+]$/', 'stdout', 'json_reformat');
        installed('exifprobe -V', '/Program: \'exifprobe\' version \d/', 'stdout');
        installed('exiftool -ver', '/^\d+\.\d/', 'stdout');
        installed('fdupes --version', '/^fdupes \d\./', 'stdout');
        installed('flac --version', '/^flac /', 'stdout');
        installed('flex --version', '/^flex \d/', 'stdout');
        installed('fontforge --version', '/^fontforge 20/', 'stdout');
        installed('gettext --version', '/GNU gettext/', 'stdout');
        installed('gpsbabel --version', '/GPSBabel Version \d/', 'stdout');
        installed('groff --version', '/^GNU groff version \d/', 'stdout');
        installed('htop --version', '/^htop \d/', 'stdout');
        installed('iotop --version', '/^iotop \d/', 'stdout');
        installed('lame --version', '/LAME .* version /', 'stdout');
        installed('lftp --version', '/^LFTP .+Version \d/', 'stdout');
        installed('lynx --version', '/^Lynx Version \d/', 'stdout');
        installed('lzip --version', '/^Lzip \d/', 'stdout');
        installed('mftrace --version', '/^mftrace \d\./', 'stdout');
        installed('mosh --version', '/^mosh \d/', 'stderr');
        installed('mutt -h', '/^Mutt \d/', 'stdout');
        installed('ncftp -v', '/Program version:\s+NcFTP /', 'stderr');
        installed('nmap --version', '/Nmap version /', 'stdout');
        installed('nodejs --version', '/^v\d+\.\d+\.\d+$/', 'stdout');
        installed('npm --version', '/^\d+\.\d+\.\d+$/', 'stdout');
        installed('pandoc --version', '/^pandoc \d\./', 'stdout');
        installed('pip3 --version', '/^pip \d/', 'stdout');
        installed('psql --version', '/psql \(PostgreSQL\)/', 'stdout');
        installed('quilt --version', '/^\d\./', 'stdout');
        installed('rtorrent -h', '/BitTorrent client version /', 'stdout');
        installed('rzip --version', '/^rzip version \d/', 'stdout');
        installed('scriptreplay --help', '/-m, --maxdelay/', 'stdout', 'scriptreplay has -m/--maxdelay');
        installed('strace -V', '/^strace -- version \d/', 'stdout');
        installed('svn --version', '/svn, version /', 'stdout');
        installed('texi2html --version', '/^\d\./', 'stdout');
        installed('tig --version', '/^tig version /', 'stdout');
        installed('tmux -V', '/^tmux \d\./', 'stdout');
        installed('trickle -V', '/^trickle: version \d/', 'stderr');
        installed('unrar --version', '/UNRAR \d/', 'stdout');
        installed('whois --version', '/^Version \d/', 'stdout');
        installed('xmllint --version', '/^xmllint: using libxml version /', 'stderr');
        installed('xmlto --version', '/^xmlto version \d/', 'stdout');
        installed('xz --version', '/^xz \(XZ Utils\) \d/s', 'stdout');
        installed('youtube-dl --version', '/^20\d\d\.\d\d\.\d\d/', 'stdout');

    }

    if ($Opt{'gui'} || $Opt{'all'}) {

        diag("Checking graphical software...");
        installed('abiword --version', '/^\d\.\d+\.\d+/', 'stdout');
        installed('bash -c "type -p gnome-system-monitor"', '/bin\/gnome-system-monitor$/', 'stdout');
        installed('celestia --help', '/Usage:.*\bcelestia\b.+OPTION/s', 'stdout');
        installed('firefox --version', '/Mozilla Firefox \d+\.\d+/', 'stdout');
        installed('geeqie --version', '/^Geeqie \d\./', 'stderr');
        installed('gnucash --version', '/GnuCash \d\./', 'stdout');
        installed('gnumeric --version', '/^gnumeric version /', 'stdout');
        installed('gource --help', '/Gource v\d/', 'stdout');
        installed('inkscape -V', '/^Inkscape \d/', 'stdout');
        installed('mplayer -V', '/^MPlayer2 /', 'stdout');
        installed('okular --version', '/Okular: \d/', 'stdout');
        installed('qemu-system-i386 --version', '/QEMU emulator version \d/', 'stdout');
        installed('shutter -v', '/^\d+\.\d+\.\d+ Rev\.\d+/', 'stdout');
        installed('ufraw --version', '/^ufraw \d/', 'stderr');
        installed('vlc --version', '/^VLC version \d/', 'stdout');
        installed('wireshark --version', '/^wireshark \d/', 'stdout');
        installed('x264 --version', '/^x264 \d/', 'stdout');
        installed('xdot --help', '/Usage:.*\bxdot\b/s', 'stdout');
        installed('xtightvncviewer -h', '/^TightVNC Viewer /', 'stderr');

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
    return $Retval;
    # }}}
} # main()

sub installed {
    # {{{
    my ($Cmd, $Exp, $Std, $Desc) = @_;
    $Std =~ /^(both|stderr|stdout)$/ ||
        BAIL_OUT("installed(): $Cmd: Invalid stream: '$Std'");
    my $Txt = join('',
        "\"$Cmd\"",
        defined($Desc)
            ? " - $Desc"
            : ''
    );

    if ($Std eq 'stdout') {
        like(`$Cmd 2>/dev/null`, $Exp, $Txt);
    } elsif ($Std eq 'stderr') {
        like(`$Cmd 2>&1 >/dev/null`, $Exp, $Txt);
    } else {
        like(`$Cmd 2>&1`, $Exp, $Txt);
    }
    return;
    # }}}
} # installed()

sub coreutils {
    # {{{
    my @progs = @_;
    my $retval = 0;
    for my $curr (@progs) {
        my $cmd = $curr;
        if ($curr =~ /^(echo|false|kill|pwd|true|printf)$/) {
            for my $d (qw{ /usr/local/bin /usr/bin /bin }) {
                if (-x "$d/$curr") {
                    $cmd = "$d/$curr";
                    last;
                }
            }
        }
        installed("$cmd --version",
            "/^$curr .*?\\bcoreutils\\b/",
            'stdout') || ($retval = 1);
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
    defined($descriptions{$Desc}) &&
        BAIL_OUT("testcmd(): '$Desc' description is used twice");
    $descriptions{$Desc} = 1;
    my $stderr_cmd = '';
    my $cmd_outp_str = $Opt{'verbose'} >= 1 ? "\"$Cmd\" - " : '';
    my $Txt = join('', $cmd_outp_str, defined($Desc) ? $Desc : '');
    my $TMP_STDERR = "$CMD_BASENAME-stderr.tmp";
    my $retval = 1;

    if (defined($Exp_stderr)) {
        $stderr_cmd = " 2>$TMP_STDERR";
    }
    $retval &= is(`$Cmd$stderr_cmd`, $Exp_stdout, "$Txt (stdout)");
    my $ret_val = $?;
    if (defined($Exp_stderr)) {
        $retval &= is(file_data($TMP_STDERR), $Exp_stderr, "$Txt (stderr)");
        unlink($TMP_STDERR);
    } else {
        diag("Warning: stderr not defined for '$Txt'");
    }
    $retval &= is($ret_val >> 8, $Exp_retval, "$Txt (retval)");

    return $retval;
    # }}}
} # testcmd()

sub likecmd {
    # {{{
    my ($Cmd, $Exp_stdout, $Exp_stderr, $Exp_retval, $Desc) = @_;
    defined($descriptions{$Desc}) &&
        BAIL_OUT("likecmd(): '$Desc' description is used twice");
    $descriptions{$Desc} = 1;
    my $stderr_cmd = '';
    my $cmd_outp_str = $Opt{'verbose'} >= 1 ? "\"$Cmd\" - " : '';
    my $Txt = join('', $cmd_outp_str, defined($Desc) ? $Desc : '');
    my $TMP_STDERR = "$CMD_BASENAME-stderr.tmp";
    my $retval = 1;

    if (defined($Exp_stderr)) {
        $stderr_cmd = " 2>$TMP_STDERR";
    }
    $retval &= like(`$Cmd$stderr_cmd`, $Exp_stdout, "$Txt (stdout)");
    my $ret_val = $?;
    if (defined($Exp_stderr)) {
        $retval &= like(file_data($TMP_STDERR), $Exp_stderr, "$Txt (stderr)");
        unlink($TMP_STDERR);
    } else {
        diag("Warning: stderr not defined for '$Txt'");
    }
    $retval &= is($ret_val >> 8, $Exp_retval, "$Txt (retval)");

    return $retval;
    # }}}
} # likecmd()

sub file_data {
    # Return file content as a string {{{
    my $File = shift;
    my $Txt;

    open(my $fp, '<', $File) or return undef;
    local $/ = undef;
    $Txt = <$fp>;
    close($fp);
    return $Txt;
    # }}}
} # file_data()

sub print_version {
    # Print program version {{{
    print("$progname $VERSION\n");
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

Usage: $progname [options]

Check for missing necessary programs needed by some scripts.

Options:

  -a, --all
    Run all tests, also TODOs.
  -g, --gui
    Also check for programs that need a graphical environment.
  -h, --help
    Show this help.
  -o/--other
    Check for other software, programs that aren't essential for a 
    wonderful life.
  -q, --quiet
    Be more quiet. Can be repeated to increase silence.
  -t, --todo
    Run only the TODO tests.
  -v, --verbose
    Increase level of verbosity. Can be repeated.
  --version
    Print version information.

END
    exit($Retval);
    # }}}
} # usage()

sub msg {
    # Print a status message to stderr based on verbosity level {{{
    my ($verbose_level, $Txt) = @_;

    $verbose_level > $Opt{'verbose'} && return;
    print(STDERR "$progname: $Txt\n");
    return;
    # }}}
} # msg()

__END__

# This program is free software; you can redistribute it and/or modify 
# it under the terms of the GNU General Public License as published by 
# the Free Software Foundation; either version 2 of the License, or (at 
# your option) any later version.
#
# This program is distributed in the hope that it will be useful, but 
# WITHOUT ANY WARRANTY; without even the implied warranty of 
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
# See the GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License 
# along with this program.
# If not, see L<http://www.gnu.org/licenses/>.

# vim: set fenc=UTF-8 ft=perl fdm=marker ts=4 sw=4 sts=4 et fo+=w :
