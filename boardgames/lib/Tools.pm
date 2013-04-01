package lib::Tools;

use strict;
use warnings;

use Exporter qw/import/;

our @EXPORT_OK = qw( get_config get_dbh );

# CPAN
use Carp;
use DBI;
use Readonly;
use XML::Simple;

# Variables
my $CONFIG;
Readonly::Scalar my $CONFIGFILE => 'etc/config.xml';    #path to config file

=pod

=head1 NAME

lib::Tools - List of handy tools

=cut


sub get_config{
    
    if (defined $CONFIG){
        return $CONFIG;
    }
    
    my $config;
    eval {
        $config = XMLin($CONFIGFILE, KeyAttr => { database => 'dbname' }, ForceArray => [ 'database' ]); 
        1;
    }
    or do {
        confess "Error while trying to load config file $CONFIGFILE $@";
    };
    
    if (defined $config){
        $CONFIG = $config;
        return $CONFIG;
    }
    else{
        confess "Empty config loaded from $CONFIGFILE";
    }
}

sub get_dbh {
    my $database_name = shift;

    if ( !defined $database_name ) {
        confess "No database name provided";
    }

    my $config = get_config();
    my ( $host, $user, $pass, $port );

    if ( !defined $config->{$database_name} ) {
        confess "No database connection details for $database_name";
    }
    else {
        $host = $config->{$database_name}->{'host'};
        $user = $config->{$database_name}->{'user'};
        $pass = $config->{$database_name}->{'pass'};
        $port = $config->{$database_name}->{'port'};
    }

    my $dbh;

    my $dbi_connect = "DBI:Pg:dbname=$database_name;host=$host";

    eval {
        # connect
        $dbh = DBI->connect_cached( $dbi_connect, $user, $pass, { 'RaiseError' => 1 } );
        1;
    }
    or do {
        confess "Error connecting to database $@";
    };

    return $dbh;

}

1;