#!/usr/bin/perl
use XML::Simple;
use Data::Dumper;
use Getopt::Long;

my $pickedEnv;

GetOptions("env=s" => \$pickedEnv);

my $xml = new XML::Simple;
my $data = $xml->XMLin("mvnhlp.xml", ForceArray => 1, KeyAttr    => {});
my $envs = $data->{envs}[0]->{env};
my $config = {};
foreach my $env (@$envs) {
	$config->{$env->{name}} = $env->{profiles}[0]->{profile};	
}

print "Picked env: $pickedEnv, using profiles:\n" ;
my $pickedProfiles = $config->{$pickedEnv};

foreach my $profile (@$pickedProfiles){
	print "* $profile \n";
}

