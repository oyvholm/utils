#!/usr/bin/env perl

#=======================================================================
# sident.t
# File ID: 9e63b5fe-f989-11dd-9357-000475e441b9
#
# Test suite for sident(1).
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

our $CMD_BASENAME = "sident";
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
    diag("Testing without options...");
    testcmd("$CMD sident-files/textfile", # {{{
        <<'END',

sident-files/textfile:
     $Id: plain_old_textfile 93653 2008-09-22 14:15:10Z sunny $
     $Id: yeh 1234 2008-09-22 12:25:05Z sunny $
     $Id: plain_old_textfile 93653 2008-09-22 14:15:10Z sunny $
     $Id: yeh 1234 2008-09-22 12:25:05Z sunny $
     $Id: yeh 1234 2008-09-22 12:25:05Z sunny $
     $Date: 1999/12/23 21:59:22 $
     $Header: /cvsweb/cvs-guide/keyword.html,v 1.3 1999/12/23 21:59:22 markd Exp $
     $Id: keyword.html,v 1.3 1999/12/23 21:59:22 markd Exp $
     $Weirdo: blah blah $
END
        "",
        0,
        "Read textfile, no arguments",
    );

    # }}}
    testcmd("$CMD sident-files/random", # {{{
        <<'END',

sident-files/random:
     $Id: randomstuff 314159 1969-01-21 17:12:16Z sunny $
END
        "",
        0,
        "Read random binary data, no arguments",
    );

    # }}}
    diag("Testing stdin...");
    testcmd("$CMD - <sident-files/random", # {{{
        <<'END',

-:
     $Id: randomstuff 314159 1969-01-21 17:12:16Z sunny $
END
        "",
        0,
        "Read random binary data from stdin with hyphen as filename",
    );

    # }}}
    testcmd("cat sident-files/random | $CMD -", # {{{
        <<'END',

-:
     $Id: randomstuff 314159 1969-01-21 17:12:16Z sunny $
END
        "",
        0,
        "Read random binary through pipe, hyphen filename",
    );

    # }}}
    diag("Testing -e (--expanded-only) option...");
    testcmd("$CMD -e sident-files/unexpanded sident-files/textfile", # {{{
        <<'END',

sident-files/textfile:
     $Id: plain_old_textfile 93653 2008-09-22 14:15:10Z sunny $
     $Id: yeh 1234 2008-09-22 12:25:05Z sunny $
     $Id: plain_old_textfile 93653 2008-09-22 14:15:10Z sunny $
     $Id: yeh 1234 2008-09-22 12:25:05Z sunny $
     $Id: yeh 1234 2008-09-22 12:25:05Z sunny $
     $Date: 1999/12/23 21:59:22 $
     $Header: /cvsweb/cvs-guide/keyword.html,v 1.3 1999/12/23 21:59:22 markd Exp $
     $Id: keyword.html,v 1.3 1999/12/23 21:59:22 markd Exp $
     $Weirdo: blah blah $
END
        "",
        0,
        "List only expanded keywords",
    );

    # }}}
    testcmd("$CMD -ev sident-files/unexpanded sident-files/textfile", # {{{
        <<'END',

sident-files/unexpanded:

sident-files/textfile:
     $Id: plain_old_textfile 93653 2008-09-22 14:15:10Z sunny $
     $Id: yeh 1234 2008-09-22 12:25:05Z sunny $
     $Id: plain_old_textfile 93653 2008-09-22 14:15:10Z sunny $
     $Id: yeh 1234 2008-09-22 12:25:05Z sunny $
     $Id: yeh 1234 2008-09-22 12:25:05Z sunny $
     $Date: 1999/12/23 21:59:22 $
     $Header: /cvsweb/cvs-guide/keyword.html,v 1.3 1999/12/23 21:59:22 markd Exp $
     $Id: keyword.html,v 1.3 1999/12/23 21:59:22 markd Exp $
     $Weirdo: blah blah $
END
        "",
        0,
        "List only expanded keywords, plus list filename without expanded kw",
    );

    # }}}
    diag("Testing -f (--filenames-from) option...");
    testcmd("$CMD -f sident-files/filenames", # {{{
        <<'END',

sident-files/random:
     $Id: randomstuff 314159 1969-01-21 17:12:16Z sunny $

sident-files/textfile:
     $Id: plain_old_textfile 93653 2008-09-22 14:15:10Z sunny $
     $Id: yeh 1234 2008-09-22 12:25:05Z sunny $
     $Id: plain_old_textfile 93653 2008-09-22 14:15:10Z sunny $
     $Id: yeh 1234 2008-09-22 12:25:05Z sunny $
     $Id: yeh 1234 2008-09-22 12:25:05Z sunny $
     $Date: 1999/12/23 21:59:22 $
     $Header: /cvsweb/cvs-guide/keyword.html,v 1.3 1999/12/23 21:59:22 markd Exp $
     $Id: keyword.html,v 1.3 1999/12/23 21:59:22 markd Exp $
     $Weirdo: blah blah $

sident-files/unexpanded:
     $URL$
     $HeadURL$
     $LastChangedBy$
     $Date$
     $LastChangedDate$
     $Rev$
     $Revision$
     $LastChangedRevision$
     $Id$
     $RealLyuNKoWN$
END
        "",
        0,
        "Read filenames from file",
    );

    # }}}
    diag("Testing -k (--known-keywords-only) option...");
    testcmd("$CMD -k sident-files/textfile", # {{{
        <<'END',

sident-files/textfile:
     $Id: plain_old_textfile 93653 2008-09-22 14:15:10Z sunny $
     $Id: yeh 1234 2008-09-22 12:25:05Z sunny $
     $Id: plain_old_textfile 93653 2008-09-22 14:15:10Z sunny $
     $Id: yeh 1234 2008-09-22 12:25:05Z sunny $
     $Id: yeh 1234 2008-09-22 12:25:05Z sunny $
     $Date: 1999/12/23 21:59:22 $
     $Header: /cvsweb/cvs-guide/keyword.html,v 1.3 1999/12/23 21:59:22 markd Exp $
     $Id: keyword.html,v 1.3 1999/12/23 21:59:22 markd Exp $
END
        "",
        0,
        "List only known keywords",
    );

    # }}}
    diag("Testing -l (--filenames-only) option...");
    testcmd("$CMD -le sident-files/*", # {{{
        <<'END',
sident-files/random
sident-files/textfile
END
        "",
        0,
        "Only list names of files with expanded keywords",
    );

    # }}}
    diag("Testing -u (--unique-keywords) option...");
    testcmd("$CMD -u sident-files/textfile", # {{{
        <<'END',

sident-files/textfile:
     $Id: plain_old_textfile 93653 2008-09-22 14:15:10Z sunny $
     $Id: yeh 1234 2008-09-22 12:25:05Z sunny $
     $Date: 1999/12/23 21:59:22 $
     $Header: /cvsweb/cvs-guide/keyword.html,v 1.3 1999/12/23 21:59:22 markd Exp $
     $Id: keyword.html,v 1.3 1999/12/23 21:59:22 markd Exp $
     $Weirdo: blah blah $
END
        "",
        0,
        "Remove duplicates from textfile",
    );

    # }}}
    testcmd("$CMD -v sident-files/*", # {{{
        <<'END',

sident-files/filenames:

sident-files/nothing_here:

sident-files/random:
     $Id: randomstuff 314159 1969-01-21 17:12:16Z sunny $

sident-files/textfile:
     $Id: plain_old_textfile 93653 2008-09-22 14:15:10Z sunny $
     $Id: yeh 1234 2008-09-22 12:25:05Z sunny $
     $Id: plain_old_textfile 93653 2008-09-22 14:15:10Z sunny $
     $Id: yeh 1234 2008-09-22 12:25:05Z sunny $
     $Id: yeh 1234 2008-09-22 12:25:05Z sunny $
     $Date: 1999/12/23 21:59:22 $
     $Header: /cvsweb/cvs-guide/keyword.html,v 1.3 1999/12/23 21:59:22 markd Exp $
     $Id: keyword.html,v 1.3 1999/12/23 21:59:22 markd Exp $
     $Weirdo: blah blah $

sident-files/unexpanded:
     $URL$
     $HeadURL$
     $LastChangedBy$
     $Date$
     $LastChangedDate$
     $Rev$
     $Revision$
     $LastChangedRevision$
     $Id$
     $RealLyuNKoWN$
END
        "",
        0,
        "Also list files without keywords",
    );

    # }}}
    testcmd("$CMD -vx sident-files/*", # {{{
        <<'END',
<?xml version="1.0"?>
<sident>
  <file>
    <filename>sident-files/filenames</filename>
  </file>
  <file>
    <filename>sident-files/nothing_here</filename>
  </file>
  <file>
    <filename>sident-files/random</filename>
    <keywords>
      <keyword>$Id: randomstuff 314159 1969-01-21 17:12:16Z sunny $</keyword>
    </keywords>
  </file>
  <file>
    <filename>sident-files/textfile</filename>
    <keywords>
      <keyword>$Id: plain_old_textfile 93653 2008-09-22 14:15:10Z sunny $</keyword>
      <keyword>$Id: yeh 1234 2008-09-22 12:25:05Z sunny $</keyword>
      <keyword>$Id: plain_old_textfile 93653 2008-09-22 14:15:10Z sunny $</keyword>
      <keyword>$Id: yeh 1234 2008-09-22 12:25:05Z sunny $</keyword>
      <keyword>$Id: yeh 1234 2008-09-22 12:25:05Z sunny $</keyword>
      <keyword>$Date: 1999/12/23 21:59:22 $</keyword>
      <keyword>$Header: /cvsweb/cvs-guide/keyword.html,v 1.3 1999/12/23 21:59:22 markd Exp $</keyword>
      <keyword>$Id: keyword.html,v 1.3 1999/12/23 21:59:22 markd Exp $</keyword>
      <keyword>$Weirdo: blah blah $</keyword>
    </keywords>
  </file>
  <file>
    <filename>sident-files/unexpanded</filename>
    <keywords>
      <keyword>$URL$</keyword>
      <keyword>$HeadURL$</keyword>
      <keyword>$LastChangedBy$</keyword>
      <keyword>$Date$</keyword>
      <keyword>$LastChangedDate$</keyword>
      <keyword>$Rev$</keyword>
      <keyword>$Revision$</keyword>
      <keyword>$LastChangedRevision$</keyword>
      <keyword>$Id$</keyword>
      <keyword>$RealLyuNKoWN$</keyword>
    </keywords>
  </file>
</sident>
END
        "",
        0,
        "Output XML, including files without keywords",
    );

    # }}}
    diag("Testing -x (--xml) option...");
    testcmd("$CMD -x sident-files/textfile", # {{{
        <<'END',
<?xml version="1.0"?>
<sident>
  <file>
    <filename>sident-files/textfile</filename>
    <keywords>
      <keyword>$Id: plain_old_textfile 93653 2008-09-22 14:15:10Z sunny $</keyword>
      <keyword>$Id: yeh 1234 2008-09-22 12:25:05Z sunny $</keyword>
      <keyword>$Id: plain_old_textfile 93653 2008-09-22 14:15:10Z sunny $</keyword>
      <keyword>$Id: yeh 1234 2008-09-22 12:25:05Z sunny $</keyword>
      <keyword>$Id: yeh 1234 2008-09-22 12:25:05Z sunny $</keyword>
      <keyword>$Date: 1999/12/23 21:59:22 $</keyword>
      <keyword>$Header: /cvsweb/cvs-guide/keyword.html,v 1.3 1999/12/23 21:59:22 markd Exp $</keyword>
      <keyword>$Id: keyword.html,v 1.3 1999/12/23 21:59:22 markd Exp $</keyword>
      <keyword>$Weirdo: blah blah $</keyword>
    </keywords>
  </file>
</sident>
END
        "",
        0,
        "Output XML from textfile",
    );

    # }}}
    testcmd("$CMD -ux sident-files/textfile", # {{{
        <<'END',
<?xml version="1.0"?>
<sident>
  <file>
    <filename>sident-files/textfile</filename>
    <keywords>
      <keyword>$Id: plain_old_textfile 93653 2008-09-22 14:15:10Z sunny $</keyword>
      <keyword>$Id: yeh 1234 2008-09-22 12:25:05Z sunny $</keyword>
      <keyword>$Date: 1999/12/23 21:59:22 $</keyword>
      <keyword>$Header: /cvsweb/cvs-guide/keyword.html,v 1.3 1999/12/23 21:59:22 markd Exp $</keyword>
      <keyword>$Id: keyword.html,v 1.3 1999/12/23 21:59:22 markd Exp $</keyword>
      <keyword>$Weirdo: blah blah $</keyword>
    </keywords>
  </file>
</sident>
END
        "",
        0,
        "Output XML, remove duplicates",
    );

    # }}}
    diag("Error conditions...");
    testcmd("$CMD sident-files", # {{{
        "",
        "",
        0,
        "Ignore directories",
    );

    # }}}
    testcmd("$CMD -v sident-files", # {{{
        "",
        "",
        0,
        "Ignore directories, even with --verbose",
    );

    # }}}
    likecmd("$CMD sident-files/shbvkdsvsdfv", # {{{
        '/^$/',
        '/^sident: sident-files/shbvkdsvsdfv: .*$/',
        1,
        "File not found",
    );

    # }}}
    likecmd("$CMD -x sident-files/shbvkdsvsdfv", # {{{
        '/^<\?xml version="1\.0"\?>\n<sident>\n<\/sident>$/',
        '/^sident: sident-files/shbvkdsvsdfv: .*$/',
        1,
        "File not found, don’t break the XML",
    );

    # }}}
    diag("Validate POD (Plain Old Documentation)");
    testcmd("podchecker $CMD", # {{{
        "",
        "$CMD pod syntax OK.\n",
        0,
        "$CMD contains valid POD",
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
    my $cmd_outp_str = $Opt{'verbose'} >= 1 ? "\"$Cmd\" - " : '';
    my $Txt = join('',
        $cmd_outp_str,
        defined($Desc)
            ? $Desc
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
    my $cmd_outp_str = $Opt{'verbose'} >= 1 ? "\"$Cmd\" - " : '';
    my $Txt = join('',
        $cmd_outp_str,
        defined($Desc)
            ? $Desc
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
