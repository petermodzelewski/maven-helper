#!/usr/bin/perl
use XML::Simple;
use Data::Dumper;
use Getopt::Long;

my $xmlFile = "mvnhlp.xml";

my $pickedEnv;

GetOptions("env=s" => \$pickedEnv);

my $xml = new XML::Simple;
my $data = $xml->XMLin($xmlFile, ForceArray => 1, KeyAttr    => {});

$envsConfig = parseEnvs($data);
if (! exists $envsConfig->{$pickedEnv}) {
    configError("$pickedEnv not configured"); 			
}

print "Picked env: $pickedEnv, using profiles:\n" ;
my $pickedProfiles = $envsConfig->{$pickedEnv};

foreach my $profile (@$pickedProfiles){
	print "* $profile \n";
}

sub configError {
	$msg = $_[0];
	print "$msg, check configuration in $xmlFile";
	exit 1;
}

sub parseEnvs {
	my $envs = $_[0]->{envs}[0]->{env};
	
	my $config = {};
	foreach my $env (@$envs) {
		$config->{$env->{name}} = $env->{profiles}[0]->{profile};	
	}	
	return $config;
}