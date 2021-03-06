#!/usr/bin/perl
# Fast kill
# Author: Robertof
# Description: kill & restart bot from irc
# Usage: ^C (kill) or ^R (restart)
# WARNING: CONFIGURE MODULE IN 'NEW' METHOD!
# Licence: GNU/GPL v3

package Plib::modules::fastkill;
use warnings;

# /!\ CONFIGURE PLUGIN HERE !! /!\ #
sub new {
	# -- begin configuration -- #
	my @owners = ("Robertof"); # Who can kill and restart bot?
	my $id_check = 1; # Should bot check if the owners are identified? (this makes 100% safe admin-functions of the plugin, but requires /msg nickserv identify)
	# -- end   configuration -- #
	my $options = {
		"owners" => \@owners,
		"idchk"  => $id_check
	};
	bless $options, $_[0];
	return $options;
}

sub depends {
	return [] unless $_[0]->{"idchk"};
	return ["idcheck"];
}

sub atInit {};
sub atWhile {
	my ($self, $isTest, $botClass, $sent, $nick, $ident, $host) = @_;
	return 1 if $isTest;
	my $info;
	if ($nick and $ident and $host and $info = $botClass->matchMsg ($sent, 1)) {
		if ($info->{"message"} =~ /^\^C$/ and $self->havePerms ($nick, $botClass)) {
			$botClass->sendMsg ($info->{"chan"}, "Gotta go, bye!");
			$botClass->secureQuit ("PlIB: modular, RFC-compliant and nice IRC bot - killed by ${nick}");
		} elsif ($info->{"message"} =~ /^\^R$/ and $self->havePerms ($nick, $botClass)) {
			$botClass->sendMsg ($info->{"chan"}, "Restarting bot :O");
			system ("perl $0 >/dev/null &");
			$botClass->secureQuit ("PlIB: modular, RFC-compliant and nice IRC bot - restarted by ${nick}");
		}
	}
}
	
sub havePerms {
	my ($self, $nick, $mainClass) = @_;
	return 0 if not $mainClass->{"functions"}->in_array ($self->{"owners"}, $nick);
	return ( $self->{"idchk"} ? $mainClass->{"hooked_modules"}->{"idcheck"}->isIdentified ($nick, $mainClass) : 1 );
}

1;
