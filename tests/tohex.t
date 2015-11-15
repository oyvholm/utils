#!/usr/bin/env perl

#=======================================================================
# tohex.t
# File ID: 93717826-f988-11dd-8870-000475e441b9
#
# Test suite for tohex(1).
#
# Character set: UTF-8
# ©opyleft 2008– Øyvind A. Holm <sunny@sunbase.org>
# License: GNU General Public License version 2 or later, see end of 
# file for legal stuff.
#=======================================================================

use strict;
use warnings;

BEGIN {
    use Test::More qw{no_plan};
    # use_ok() goes here
}

use Getopt::Long;

local $| = 1;

our $CMD_BASENAME = "tohex";
our $CMD = "../$CMD_BASENAME";

our %Opt = (

    'all' => 0,
    'help' => 0,
    'quiet' => 0,
    'todo' => 0,
    'verbose' => 0,
    'version' => 0,

);

our $progname = $0;
$progname =~ s/^.*\/(.*?)$/$1/;
our $VERSION = '0.1.0';

my %descriptions = ();

Getopt::Long::Configure('bundling');
GetOptions(

    'all|a' => \$Opt{'all'},
    'help|h' => \$Opt{'help'},
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

    diag(sprintf('========== Executing %s v%s ==========',
        $progname,
        $VERSION));

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

    diag('Testing -h (--help) option...');
    likecmd("$CMD -h", # {{{
        '/  Show this help/i',
        '/^$/',
        0,
        'Option -h prints help screen',
    );

    # }}}
    diag('Testing -v (--verbose) option...');
    likecmd("$CMD -hv", # {{{
        '/^\n\S+ \d+\.\d+\.\d+(\+git)?\n/s',
        '/^$/',
        0,
        'Option -v with -h returns version number and help screen',
    );

    # }}}
    diag('Testing --version option...');
    likecmd("$CMD --version", # {{{
        '/^\S+ \d+\.\d+\.\d+(\+git)?\n/',
        '/^$/',
        0,
        'Option --version returns version number',
    );

    # }}}
    testcmd("$CMD file.bin", # {{{
        '',
        "tohex: file.bin: Unknown command line argument\n",
        1,
        'No command line arguments allowed',
    );

    # }}}
    testcmd("echo This is it. | $CMD", # {{{
        "54 68 69 73 20 69 73 20 69 74 2e 0a\n",
        '',
        0,
        'ASCII to hex',
    );

    # }}}
    testcmd("echo This is it. | $CMD -d", # {{{
        "84 104 105 115 32 105 115 32 105 116 46 10\n",
        '',
        0,
        'ASCII to decimal output (-d)',
    );

    # }}}
    testcmd("echo This is a somewhat longer test. With ☮, ❤ and Linux. Oh, and €. | $CMD", # {{{
        <<END,
54 68 69 73 20 69 73 20 61 20 73 6f 6d 65 77 68
61 74 20 6c 6f 6e 67 65 72 20 74 65 73 74 2e 20
57 69 74 68 20 e2 98 ae 2c 20 e2 9d a4 20 61 6e
64 20 4c 69 6e 75 78 2e 20 4f 68 2c 20 61 6e 64
20 e2 82 ac 2e 0a
END
        '',
        0,
        "Hex output, wrap every 16th byte",
    );

    # }}}
    testcmd("echo This is a somewhat longer test. With ☮, ❤ and Linux. Oh, and €. | $CMD -d", # {{{
        <<END,
84 104 105 115 32 105 115 32 97 32 115 111 109 101 119 104
97 116 32 108 111 110 103 101 114 32 116 101 115 116 46 32
87 105 116 104 32 226 152 174 44 32 226 157 164 32 97 110
100 32 76 105 110 117 120 46 32 79 104 44 32 97 110 100
32 226 130 172 46 10
END
        '',
        0,
        "Decimal output, with wrap every 16th byte",
    );

    # }}}
    testcmd("echo -n This is 16 chars | $CMD", # {{{
        "54 68 69 73 20 69 73 20 31 36 20 63 68 61 72 73\n",
        '',
        0,
        'No extra LF at the end',
    );

    # }}}
    testcmd("echo We have ☮, ❤ and Linux. Oh, and €. | $CMD -u", # {{{
        <<END,
57 65 20 68 61 76 65 20 262e 2c 20 2764 20 61 6e 64
20 4c 69 6e 75 78 2e 20 4f 68 2c 20 61 6e 64 20
20ac 2e 0a
END
        '',
        0,
        'Hex and Unicode mode (-u)',
    );

    # }}}
    testcmd("echo We have ☮, ❤ and Linux. Oh, and €. | $CMD -d --unicode", # {{{
        <<END,
87 101 32 104 97 118 101 32 9774 44 32 10084 32 97 110 100
32 76 105 110 117 120 46 32 79 104 44 32 97 110 100 32
8364 46 10
END
        '',
        0,
        'Decimal and Unicode mode (--unicode)',
    );

    # }}}
    testcmd("$CMD -u <tohex-files/utf8.txt", # {{{
        <<END,
2554 2550 2550 2550 2550 2550 2550 2550 2550 2550 2550 2550 2550 2550 2550 2550
2550 2550 2550 2550 2550 2550 2550 2550 2550 2550 2557 0a 2551 20 20 4a
61 77 6f 68 6c 2c 20 6d 65 69 6e 20 4d 61 64 6f
6e 6e 61 20 20 20 2551 0a 2551 20 20 20 20 20 20 20
20 20 20 20 20 20 20 20 20 20 20 20 20 20 20 20
20 20 2551 0a 2551 20 20 4c 65 69 64 69 20 4d 61 64
e5 6e 6e 61 20 20 20 20 20 20 20 20 20 20 2551 0a
2551 20 20 6b 6a 69 6c 64 72 65 6e 20 e6 74 74 20
6a e5 72 20 66 69 69 74 20 20 2551 0a 2551 20 20 77
e5 6e 64 65 72 20 68 e5 75 20 6a 75 20 6d e6 6e
65 64 73 6a 20 20 2551 0a 2551 20 20 74 6f 20 6d 65
69 6b 20 65 6e 64 73 20 6d 69 69 74 20 2764 20 20
20 20 2551 0a 255a 2550 2550 2550 2550 2550 2550 2550 2550 2550 2550 2550
2550 2550 2550 2550 2550 2550 2550 2550 2550 2550 2550 2550 2550 2550 255d 0a
END
        '',
        0,
        'Open file, read UTF-8 and output hex (-u)',
    );

    # }}}
    testcmd("$CMD --unicode --decimal <tohex-files/utf8.txt", # {{{
        <<END,
9556 9552 9552 9552 9552 9552 9552 9552 9552 9552 9552 9552 9552 9552 9552 9552
9552 9552 9552 9552 9552 9552 9552 9552 9552 9552 9559 10 9553 32 32 74
97 119 111 104 108 44 32 109 101 105 110 32 77 97 100 111
110 110 97 32 32 32 9553 10 9553 32 32 32 32 32 32 32
32 32 32 32 32 32 32 32 32 32 32 32 32 32 32 32
32 32 9553 10 9553 32 32 76 101 105 100 105 32 77 97 100
229 110 110 97 32 32 32 32 32 32 32 32 32 32 9553 10
9553 32 32 107 106 105 108 100 114 101 110 32 230 116 116 32
106 229 114 32 102 105 105 116 32 32 9553 10 9553 32 32 119
229 110 100 101 114 32 104 229 117 32 106 117 32 109 230 110
101 100 115 106 32 32 9553 10 9553 32 32 116 111 32 109 101
105 107 32 101 110 100 115 32 109 105 105 116 32 10084 32 32
32 32 9553 10 9562 9552 9552 9552 9552 9552 9552 9552 9552 9552 9552 9552
9552 9552 9552 9552 9552 9552 9552 9552 9552 9552 9552 9552 9552 9552 9565 10
END
        '',
        0,
        'Read from file, use --decimal and --unicode',
    );

    # }}}
    testcmd("$CMD <tohex-files/random256.bin", # {{{
        <<END,
4a a7 39 a3 8b 3e 9b 1f 6c 6b b1 12 fb 17 c4 ba
ad 68 9a ee de ce 4f ac df af fd b3 eb ff a5 b0
dc c1 31 48 b6 9c ec ea 25 fa 7f 43 83 a0 84 70
3a 97 26 13 8c 0c 81 c2 d4 f5 93 5e 22 e1 8f 03
f1 1b 55 cf 89 f6 4d e9 7c cd 7b f7 c8 51 56 4e
6e f8 a8 80 77 a1 0a dd b8 bf 65 3d 2d cb 2f be
62 fe db bc d9 d2 99 e3 2a 37 33 53 6a 5b 0e 4b
0f 82 79 6f d0 aa 7e f0 2b 61 5d 40 66 b5 34 d3
45 24 88 c5 e7 72 a2 f2 8e ae 42 bd 1a f4 10 b9
49 7a 91 41 67 ef a9 09 15 a6 da 6d ed 2c e5 d6
18 e4 fc 98 0d ab d7 0b 1e 90 c3 c0 5f 86 16 c6
2e a4 1d 14 71 e0 3c 87 96 e6 f9 b7 32 94 20 ca
3b 4c 8d 63 19 bb cc 02 11 5a e2 60 d1 73 e8 00
3f 52 b2 d8 92 07 74 8a 01 04 c7 85 d5 05 78 36
9f c9 5c b4 21 f3 06 46 95 30 9e 27 28 58 35 75
76 7d 47 44 50 1c 57 64 29 9d 38 69 54 23 08 59
END
        '',
        0,
        'Read from binary file, output hex',
    );

    # }}}
    testcmd("$CMD -d <tohex-files/random256.bin", # {{{
        <<END,
74 167 57 163 139 62 155 31 108 107 177 18 251 23 196 186
173 104 154 238 222 206 79 172 223 175 253 179 235 255 165 176
220 193 49 72 182 156 236 234 37 250 127 67 131 160 132 112
58 151 38 19 140 12 129 194 212 245 147 94 34 225 143 3
241 27 85 207 137 246 77 233 124 205 123 247 200 81 86 78
110 248 168 128 119 161 10 221 184 191 101 61 45 203 47 190
98 254 219 188 217 210 153 227 42 55 51 83 106 91 14 75
15 130 121 111 208 170 126 240 43 97 93 64 102 181 52 211
69 36 136 197 231 114 162 242 142 174 66 189 26 244 16 185
73 122 145 65 103 239 169 9 21 166 218 109 237 44 229 214
24 228 252 152 13 171 215 11 30 144 195 192 95 134 22 198
46 164 29 20 113 224 60 135 150 230 249 183 50 148 32 202
59 76 141 99 25 187 204 2 17 90 226 96 209 115 232 0
63 82 178 216 146 7 116 138 1 4 199 133 213 5 120 54
159 201 92 180 33 243 6 70 149 48 158 39 40 88 53 117
118 125 71 68 80 28 87 100 41 157 56 105 84 35 8 89
END
        '',
        0,
        'Read from binary file, output decimal',
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

    diag('Testing finished.');
    return($Retval);
    # }}}
} # main()

sub testcmd {
    # {{{
    my ($Cmd, $Exp_stdout, $Exp_stderr, $Exp_retval, $Desc) = @_;
    defined($descriptions{$Desc}) &&
        BAIL_OUT("testcmd(): '$Desc' description is used twice");
    $descriptions{$Desc} = 1;
    my $stderr_cmd = '';
    my $Txt = join('',
        "\"$Cmd\"",
        defined($Desc)
            ? " - $Desc"
            : ''
    );
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
    return($retval);
    # }}}
} # testcmd()

sub likecmd {
    # {{{
    my ($Cmd, $Exp_stdout, $Exp_stderr, $Exp_retval, $Desc) = @_;
    defined($descriptions{$Desc}) &&
        BAIL_OUT("likecmd(): '$Desc' description is used twice");
    $descriptions{$Desc} = 1;
    my $stderr_cmd = '';
    my $Txt = join('',
        "\"$Cmd\"",
        defined($Desc)
            ? " - $Desc"
            : ''
    );
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
    return($retval);
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

Usage: $progname [options] [file [files [...]]]

Contains tests for the $CMD_BASENAME(1) program.

Options:

  -a, --all
    Run all tests, also TODOs.
  -h, --help
    Show this help.
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

    if ($Opt{'verbose'} >= $verbose_level) {
        print(STDERR "$progname: $Txt\n");
    }
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
