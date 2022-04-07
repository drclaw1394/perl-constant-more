package constant::more;

use version; our $VERSION=version->declare("v0.1.0");
use strict;
use warnings;

use feature qw<refaliasing state>;
no warnings "experimental";
use List::Util qw<pairs>;

#use Getopt::Long;
use Data::Dumper;
$Data::Dumper::Deparse=1;

use Carp qw<croak carp>;

our %seen;

use Exporter;
sub import {

	my $package =shift;
	return unless @_;
	#check if first item is a hash ref.
	my $flags;
	if(ref($_[0]) eq "HASH"){
		$flags=shift;
	}
	elsif(ref($_[0]) eq ""){
		#flat list of 2 items expected
		$flags={$_[0]=>$_[1]};
	}
	else {
		croak "Flat list or hash ref expected";
	}
	
	
	# Process each entry
	# The keys of the hash are the full names of the constants to declare
	# if now package is prefixed, they are added to the callers package
	
	my $caller=caller;
	no strict "refs";
	my %table;

	for  my $name (keys %$flags){
		my $entry;
		my $value;
		my @values;


		if(ref($flags->{$name}) eq "HASH"){
			#Full declaration
			$entry=$flags->{$name};
		}
		else {
			#assumed a short cut, just name and value
			$entry={val=>$flags->{$name}, force=>undef,opt=>undef, env=>undef};
		}

		#Default sub is to return the key value pair
		my $sub=$entry->{sub}//= sub {
			#return name value pair
			$name, $_[1];
		};

		#Set the entry by name
		$flags->{$name}=$entry;

		my $success;
		my $wrapper= sub {
			my  ($opt_name, $opt_value)=@_;

			

			return unless @_>=2;

			my @results=&$sub;


			#set values in the table
			for my $pair (pairs @results){
				my $value=$pair->[1];
				my $name=$pair->[0];
				unless($name=~/::/){
					$name=$caller."::".$name;
				}
				$table{$name}=$value;
			}

			$success=1;

		};


		#if(!$success){
			#Select a value 
			$wrapper->("", $entry->{val});	#default
			
			#}

		#CMD line argument override
		if($entry->{opt}){	
			require Getopt::Long;
			my $parser=Getopt::Long::Parser->new(
				config=>[
					"pass_through"
				]
			);
			#TODO: test the type char of options spec to ensure $value is the same
			$parser->getoptions( $entry->{opt}, $wrapper) or die "Invalid options";
		}

		if(!$success and $entry->{env}){
		#Env override
			if(defined $ENV{$entry->{env}}){
				$wrapper->($ENV{$entry->{env}});
			}
		}

                ####################################################
                # if(!$success){                                   #
                #         #Select a value                          #
                #         $wrapper->("", $entry->{val});  #default #
                #                                                  #
                # }                                                #
                ####################################################
	}

			#Actually
			#Create the constants
			while(my($name,$val)=each %table){
				#my $val=$pair->[1];
				#my $name=$pair->[0];
				#check where to install the constant
				unless($seen{$name}){
					#Define
					*{$name}=sub (){$val};
					$seen{$name}=1;
					next;

				}

                                #####################################################
                                # #Attempt to locate an existing constant           #
                                # if( $seen{$name} and $entry->{force}){            #
                                #         #                                         #
                                #         *{$name}=sub (){$val} if $entry->{force}; #
                                #         next;                                     #
                                # }                                                 #
                                #####################################################
				else {
					#carp "Definition found for $name but not using new value\n";
					next;
				}
			}
}

1;
