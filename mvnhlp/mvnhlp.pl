#!/usr/bin/perl
use XML::Simple;
use Data::Dumper;
use Getopt::Long;

my $xmlFile = "mvnhlp.xml";

my $pickedEnv;

GetOptions("env=s" => \$pickedEnv);

my $xml = new XML::Simple;
my $data = $xml->XMLin($xmlFile, ForceArray => 1, KeyAttr    => {});
my $envs = $data->{envs}[0]->{env};
my $config = {};
foreach my $env (@$envs) {
	$config->{$env->{name}} = $env->{profiles}[0]->{profile};	
}

if (! exists $config->{$pickedEnv}) {
	print "$pickedEnv not configured, check configuration in $xmlFile";
	exit 1;
}

print "Picked env: $pickedEnv, using profiles:\n" ;
my $pickedProfiles = $config->{$pickedEnv};

foreach my $profile (@$pickedProfiles){
	print "* $profile \n";
}

