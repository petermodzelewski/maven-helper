#!/usr/bin/perl
use XML::Simple;
use Data::Dumper;
use Getopt::Long;

my $xmlFile = "mvnhlp.xml";
my $pickedEnv;
my $pickedApp;
my $help;

### Reading configuration ###

my $xml = new XML::Simple;
my $data = $xml->XMLin($xmlFile, ForceArray => 1, KeyAttr    => {});
$envsConfig = parseEnvs($data);
$appsConfig = parseApps($data);

### Handling arguments ###
GetOptions(	"env=s" => \$pickedEnv, 
			"app=s" => \$pickedApp,
			"list"  => \$list,
			"help" => \$help);
			
if($help) {
	printHelp();
}

if($list) {
	printList();
}

if(!$pickedEnv){
	argsError("--env");	
}

if(!$pickedApp) {
	argsError("--app");
}

if (! exists $envsConfig->{$pickedEnv}) {
    configError("$pickedEnv not configured"); 			
}

$pickedAppConfig = pickAppConfig($pickedApp);

### WORK HERE ###
print "Picked env: $pickedEnv, using profiles:\n" ;
my $pickedProfiles = $envsConfig->{$pickedEnv};

foreach my $profile (@$pickedProfiles){
	print "* $profile \n";
}

### Helper functions ###

sub pickAppConfig {
	$search = $_[0];
	@candidates = ();
	foreach $name ( keys $appsConfig ) {
		if ($name =~ m/$search/i) {
			push(@candidates, $name);
		}
	}
	$size = scalar(@candidates);
	if($size == 0) {
		print "Cannot match '$search' to any configured applications.\n";
		printAppList();
		exit(1);
	} 
	if($size == 1){
		return @candidates[0];
	}
	
	print "Pattern '$search' matches more than one application:\n";
	printPoints(@candidates);
	exit(1);
}

sub parseEnvs {
	my $envs = $_[0]->{envs}[0]->{env};
	
	my $config = {};
	foreach my $env (@$envs) {
		$config->{$env->{name}} = $env->{profiles}[0]->{profile};	
	}	
	return $config;
}

sub parseApps {
	my $apps = $_[0]->{applications}[0]->{application};
	my $config = {};
	foreach my $app (@$apps) {
		$appConfig = {};
		$appConfig->{name} = $app->{name};
		$appConfig->{pom} = $app->{pom}[0];
		$appConfig->{envs} = parseEnvs($app);
		$config->{$appConfig->{name}} = $appConfig;
	}
	return $config;
}

sub configError {
	$msg = $_[0];
	print "$msg, check configuration in $xmlFile";
	exit 1;
}


sub argsError {
	$msg = $_[0];
	print "$msg not set, see help for details \n\n";
	printHelp();
}

sub printList {	
	printEnvList();
	printAppList();
	
	exit 1;
}

sub printEnvList {
	print "Configured envs:\n";	
	printPoints(keys $envsConfig);	
}

sub printAppList {
	print "\nConfigured apps:\n";	
	print printPoints(keys $appsConfig);	
}

sub printPoints {	
    foreach $element( @_ ) {
			print "\t * $element \n";
	}
}

sub printHelp {
	print "usage mvnhlp (options) ... \n";
	print "\n\n";
	print "Parameters:\n";
	print "\t --env=ENV -e ENV: to specify environment to target\n";
	print "\t --app=APP_NAME -a APP_NAME: to specify application to work on";
	print "\t --list: lists evailable applications and envs";
	print "\t --help -h: shows this message\n";
	exit 1;
}