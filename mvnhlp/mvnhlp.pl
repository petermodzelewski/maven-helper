#!/usr/bin/perl
use XML::Simple;
use Data::Dumper;
use Getopt::Long;
use Win32::Console::ANSI;
use Term::ANSIColor;

my $xmlFile = "mvnhlp.xml";

### Reading configuration ###

my $xml = new XML::Simple;
my $data = $xml->XMLin($xmlFile, ForceArray => 1, KeyAttr    => {});
$envsConfig = parseEnvs($data);
$appsConfig = parseApps($data);

### Handling arguments ###
GetOptions(	"env=s" => \$pickedEnv, 
			"app=s" => \$pickedApp,
			"pattern=s" => \$appPatern,
			"P=s" => \$pickedProfile,
			"list"  => \$list,
			"help" => \$help);
			
if($help) {
	printHelp();
}

if($list) {
	printList();
}

if(!$pickedEnv && !$pickedProfile){
	argsError("--env or -P");	
}

if(!$pickedApp && !$appPatern) {
	argsError("--app or --pattern");
}

### WORK HERE ###
my @pickedAppConfigs = pickAppConfigs();

foreach my $pickedAppConfig (@pickedAppConfigs) {
	my $pickedAppName = $pickedAppConfig->{name};
	print "Picked app: " ;
	printInfo($pickedAppName);
	print "\n" ;

	my @pickedProfiles = ($pickedProfile);
	
	if(!$pickedProfile){
		$tmp = pickEnvConfig($pickedEnv, $pickedAppConfig);
		@pickedProfiles = @$tmp; 
		print "Picked env: $pickedEnv, using profiles:\n" ;
		printPoints(@pickedProfiles);		
	} else {
		print "Using set profile: $pickedProfile\n";
		
	}	

	$mvnCmd = join(" ", @ARGV);

	foreach my $profile (@pickedProfiles){
		$pom = $pickedAppConfig->{pom};
		$cmd = "mvn $mvnCmd -f $pom -P $profile";	
		printInfo("\n$cmd\n\n");	
		system($cmd);
	}
}

### Helper functions ###

sub pickAppConfigs {
	my @result = ();
	if(!$appPatern){
		@result = (pickAppConfig($pickedApp));
	} else {
		if ($appPatern =~ m/^all$/i) {			
			foreach $conf (values($appsConfig)){
				push(@result, $conf);
			}
		} else {		 	
			foreach $name (filterAppConfigByPattern($appPatern)) {
				push(@result, $appsConfig->{$name});
			}
		}
	}
	return @result;
}

sub pickAppConfig {
	$search = $_[0];
	@candidates = filterAppConfigByPattern($search);	
	$size = scalar(@candidates);
	if($size == 0) {
		print "Cannot match '$search' to any configured applications.\n";
		printAppList();
		exit(1);
	} 
	if($size == 1){
		return $appsConfig->{@candidates[0]};
	}
	
	print "Pattern '$search' matches more than one application:\n";
	printPoints(@candidates);
	exit(1);
}

sub filterAppConfigByPattern {
	$search = $_[0];
	@candidates = ();
	foreach $name ( keys $appsConfig ) {
		if ($name =~ m/$search/i) {
			push(@candidates, $name);
		}
	}
	return @candidates;
}

sub pickEnvConfig() {
	$env = $_[0];
	$appConfig = $_[1];
	if(exists $appConfig->{envs}->{$env}){
		print "Taking overwritten env profiles from application config\n";
		return $appConfig->{envs}->{$env};
	}
	if (! exists $envsConfig->{$env}) {
		configError("Env '$pickedEnv' not configured"); 			
	}
	return $envsConfig->{$env};
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
	print "usage: mvnhlp (options) maven_command_list \n";
	print "\n\n";
	print "Examles:\n";
	print color "bold";
	print "\t mvnhlp --env=prod --app=CoolApp clean install\n";
	print "\t mvnhlp --env=test --app=CoolApp clean war:war tomcat:redeploy\n";
	print "\t mvnhlp --env=test --pattern=Service clean war:war tomcat:redeploy\n";
	print "\t mvnhlp -P tomcat1 --pattern=all clean war:war tomcat:redeploy\n";
	print "\t mvnhlp --list\n";
	print "\n\n";
	print color 'reset';
	print "Parameters:\n";
	printParam("-P MVN_PROFILE", "to specify profile");	
	printParam("--env=ENV", "to specify environment to target");		
	printParam("--app=APP_NAME", "tto specify application to work on, or use");	
	printParam("--pattern=APP_NAME_PATTERN", "command will be used to each application, which name matches pattern. use 'all' to run command list on every application");	
	printParam("--list", "lists evailable applications and envs");	
	printParam("--help", "shows this message");	
	exit 1;
}

sub printParam() {
	$param = $_[0];
	$description = $_[1];
	print "\t";
	printInfo($param);
	print " $description\n";
}

sub printInfo() {
	$text = $_[0];
	printInColor($text, "bold green");
}

sub printInColor(){
	$text = $_[0];
	$color = $_[1];
	print color $color;
	print "$text";
	print color 'reset';
}