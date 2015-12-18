#!/usr/bin/env perl

#=======================================================================
# perlmodules.t
# File ID: a2e25ad4-56fe-11e0-8c2f-00023faf1383
#
# Find missing Perl modules.
#
# Character set: UTF-8
# ©opyleft 2011– Øyvind A. Holm <sunny@sunbase.org>
# License: GNU General Public License version 2 or later, see end of 
# file for legal stuff.
#=======================================================================

use strict;
use warnings;

BEGIN {
    use Test::More qw{no_plan};
    # use_ok() goes here

    use lib "$ENV{HOME}/bin/Lib/perllib";
    use lib "$ENV{HOME}/bin/src/fldb";
    use lib "$ENV{HOME}/bin/src/gpstools";

}

use Getopt::Long;

local $| = 1;

our $CMD_BASENAME = "";
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

    my %Modules = (

        'Authen::SASL' => 'libauthen-sasl-perl',
        'CGI' => '',
        'Cwd' => '',
        'DBI' => 'libdbi-perl',
        'Data::Dumper' => '',
        'Date::Manip' => 'libdate-manip-perl',
        'Devel::GDB' => 'libdevel-gdb-perl',
        'Devel::NYTProf' => 'libdevel-nytprof-perl',
        'Devel::ptkdb' => 'libdevel-ptkdb-perl',
        'Digest::CRC' => 'libdigest-crc-perl',
        'Digest::MD5' => 'libdigest-md5-file-perl',
        'Digest::SHA' => 'libdigest-sha-perl',
        'Env' => '',
        'Exporter' => '',
        'FLDBdebug' => '', # mine
        'FLDBpg' => '', # mine
        'FLDBsum' => '', # mine
        'FLDButf' => '', # mine
        'Fcntl' => '',
        'File::Basename' => '',
        'File::Copy' => '',
        'File::Find' => '',
        'File::Glob' => '',
        'File::Path' => '',
        'File::Spec' => '',
        'File::Temp' => '',
        'FileHandle' => '',
        'GPST' => '', # mine
        'GPSTdate' => '', # mine
        'GPSTdebug' => '', # mine
        'GPSTgeo' => '', # mine
        'GPSTxml' => '', # mine
        'Getopt::Long' => '',
        'Getopt::Std' => '',
        'GraphViz' => 'libgraphviz-perl',
        'HTML::Template' => 'libhtml-template-perl',
        'HTML::TreeBuilder' => 'libxml-treebuilder-perl libhtml-treebuilder-xpath-perl',
        'HTML::WikiConverter' => 'libhtml-wikiconverter-mediawiki-perl',
        'IO::Handle' => '',
        'IPC::Open3' => '',
        'Image::ExifTool' => 'libimage-exiftool-perl',
        'JSON::XS' => 'libjson-xs-perl',
        'MIME::Base64' => 'libmime-base64-urlsafe-perl',
        'Math::Round' => 'libmath-round-perl',
        'Module::Starter' => 'libmodule-starter-perl',
        'Module::Starter::Plugin::CGIApp' => 'libmodule-starter-plugin-cgiapp-perl',
        'Net::SMTP::SSL' => 'libnet-smtp-ssl-perl',
        'Number::Bytes::Human' => 'libnumber-bytes-human-perl',
        'OSSP::uuid' => 'libossp-uuid-perl',
        'POSIX' => '',
        'Perl::Critic' => 'libtest-perl-critic-perl',
        'Socket' => '',
        'Term::ReadLine' => '',
        'Term::ReadLine::Gnu' => 'libterm-readline-gnu-perl',
        'Term::ReadLine::Perl' => 'libterm-readline-perl-perl',
        'Test::More' => '',
        'Test::Perl::Critic' => 'libtest-perl-critic-perl',
        'Text::Diff' => 'libtext-diff-perl',
        'Time::HiRes' => '',
        'Time::Local' => '',
        'XML::Parser' => 'libxml-parser-perl',
        'bigint' => '',
        'constant' => '',
        'strict' => '',
        'utf8' => '',
        'vars' => '',

    );

    my @missing = ();
    my $outfile = './install-modules';

    unlink $outfile;
    for my $mod (sort keys %Modules) {
        my $package = $Modules{$mod};
        use_ok($mod) || length($package) && push(@missing, $package);
    }
    -e "nytprof.out" && ok(unlink("nytprof.out"), "Remove nytprof.out");

    if (scalar(@missing)) {
        open(my $fp, '>', $outfile) || die("$progname: $outfile: Cannot create file: $!\n");
        print($fp
            join("\n",
                '#!/bin/sh',
                '',
                '# Created by perlmodules.t',
                '',
                "sudo apt-get update\n",
            )
        );
        for my $m (@missing) {
            print($fp "sudo apt-get --assume-yes install $m\n");
        }
        ok(close($fp), "Close $outfile");
        ok(chmod(0755, $outfile), "Make $outfile executable");
        diag("\nExecute $outfile to install missing modules.\n\n");
        diag("Contents of $outfile:\n==== BEGIN ====\n", file_data($outfile), "==== END ====\n\n");
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
    my $Txt = defined($Desc) ? $Desc : '';
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
    my $Txt = defined($Desc) ? $Desc : '';
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

Find missing Perl modules.

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
