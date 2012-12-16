#!/usr/bin/perl

#=======================================================================
# perlmodules.t
# File ID: a2e25ad4-56fe-11e0-8c2f-00023faf1383
# Find missing Perl modules.
#
# Character set: UTF-8
# ©opyleft 2011– Øyvind A. Holm <sunny@sunbase.org>
# License: GNU General Public License version 3 or later, see end of 
# file for legal stuff.
#=======================================================================

use strict;
use warnings;

BEGIN {
    # push(@INC, "$ENV{'HOME'}/bin/STDlibdirDTS");
    use Test::More qw{no_plan};
    # use_ok() goes here

    use lib "$ENV{HOME}/bin/Lib/perllib";
    use lib "$ENV{HOME}/bin/src/fldb";
    use lib "$ENV{HOME}/bin/src/gpstools";

}

use Getopt::Long;

local $| = 1;

our $Debug = 0;
our $CMD = 'STDexecDTS';

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

my %Modules = (

    'Authen::SASL' => 'libauthen-sasl-perl',
    'CGI' => '',
    'Cwd' => '',
    'DBI' => 'libdbi-perl',
    'Data::Dumper' => '',
    'Date::Manip' => 'libdate-manip-perl',
    'Devel::GDB' => 'libdevel-gdb-perl',
    'Devel::ptkdb' => 'libdevel-ptkdb-perl',
    'Digest::CRC' => 'libdigest-crc-perl',
    'Digest::MD5' => 'libdigest-md5-file-perl',
    'Digest::SHA1' => 'libdigest-sha1-perl',
    'Env' => '',
    'Exporter' => '',
    'FLDBdebug' => '', # mine
    'FLDBpg' => '', # mine
    'FLDBsum' => '', # mine
    'FLDButf' => '', # mine
    'Fcntl' => '',
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
    'Image::ExifTool' => 'libimage-exiftool-perl',
    'MIME::Base64' => 'libmime-base64-urlsafe-perl',
    'Module::Starter' => 'libmodule-starter-perl',
    'Module::Starter::Plugin::CGIApp' => 'libmodule-starter-plugin-cgiapp-perl',
    'Net::SMTP::SSL' => 'libnet-smtp-ssl-perl',
    'OSSP::uuid' => 'libossp-uuid-perl',
    'POSIX' => '',
    'Perl::Critic' => 'libtest-perl-critic-perl',
    'Socket' => '',
    'Term::ReadLine' => '',
    'Term::ReadLine::Gnu' => 'libterm-readline-gnu-perl',
    'Term::ReadLine::Perl' => 'libterm-readline-perl-perl',
    'Test::More' => '',
    'Test::Perl::Critic' => 'libtest-perl-critic-perl',
    'Time::HiRes' => '',
    'Time::Local' => '',
    'XML::Parser' => 'libxml-parser-perl',
    'bigint' => '',
    'constant' => '',
    'strict' => '',
    'suncgi' => '', # mine
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
        print($fp "sudo apt-get install $m\n");
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
    my $TMP_STDERR = 'perlmodules-stderr.tmp';

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
    my $TMP_STDERR = 'perlmodules-stderr.tmp';

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

Find missing Perl modules.

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

perlmodules.t [options] [file [files [...]]]

=head1 DESCRIPTION

Find missing Perl modules.

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
