#!/usr/bin/perl
# mview.pl - Parses the Unix messages file and prints colorized output
#
# Copyright (C) 2010, 2011 Joachim "Joe" Stiegler <blablabla@trullowitsch.de>
# 
# This program is free software; you can redistribute it and/or modify it under the terms
# of the GNU General Public License as published by the Free Software Foundation; either
# version 3 of the License, or (at your option) any later version.
#
# This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY;
# without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
# See the GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License along with this program;
# if not, see <http://www.gnu.org/licenses/>.
#
# --
# 
# Version: 0.2 - 2011-04-02
#
# To see the output colorized within 'less', use the '-r' option 

use warnings;
use strict;
use Term::ANSIColor;
use Getopt::Std;
use POSIX;

our ($opt_f, $opt_h);

getopts("f:h");

my @os = uname();
my $sys = $os[0];
my $messages_file;

if ($sys eq "SunOS") {
	$messages_file = "/var/adm/messages";
}
elsif ($sys eq "Linux") {
	$messages_file = "/var/log/messages";
}
else {
	die "don't know where's the messages file for $sys. Try -f\n";
}

$messages_file = $opt_f if (defined($opt_f));

die "usage: $0 [-f <messages file>]\n" if (defined($opt_h));

my @messages;

open(MESSAGES, '<', $messages_file) or die "$!\n";

while(<MESSAGES>) {
	push @messages, $_;
}
	
close(MESSAGES);

foreach my $line (@messages) {
	my @message = split (' ', $line);

	# Date and Time
	print color 'bold white';
	print "$message[0] $message[1] $message[2] ";
	print color 'reset';

	# Hostname
	print color 'cyan';
	print "$message[3] ";
	print color 'reset';

	# Who
	print color 'magenta';
	print "$message[4] ";
	print color 'reset';

	for (my $i=5; $i<=scalar(@message) -1; $i++) {
		# ID begin
		if ($message[$i] =~ /^\[/) {
			print color 'bold blue';
			print "$message[$i] ";
		}
		# ID end
		elsif ($message[$i] =~ /]$/) {
			print color 'bold blue';
			print "$message[$i] ";
			print color 'reset';
		}
		# Warning event type
		elsif ($message[$i] =~ /warn/i) {
			print color 'bold yellow';
			print "$message[$i] ";
			print color 'reset';
		}
		# Critical or failure event type
		elsif ($message[$i] =~ /crit|fail/i) {
			print color 'bold red';
			print "$message[$i] ";
			print color 'reset';
		}
		# Notice event type
		elsif ($message[$i] =~ /notice/i) {
			print color 'yellow';
			print "$message[$i] ";
			print color 'reset';
		}
		# The message itself
		else {
			print "$message[$i] ";
		}
	}
	print "\n";
}
