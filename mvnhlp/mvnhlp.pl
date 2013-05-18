#!/usr/bin/perl
use XML::Simple;
use Data::Dumper;
use Getopt::Std;

my $xml = new XML::Simple;
my $data = $xml->XMLin("mvnhlp.xml");

print Dumper(getEnvsData($data));


sub getEnvsData {
	my $result = {};
	my $envs = $_[0]->{envs}->{env};
	while ( ($envName, $env) = each $envs ){		
		my @tmp = $env->{profiles}->{profile};		
		$result->{$envName} = \@tmp;		
	}
	return $result;
}