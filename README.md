# NAME

constant::more - Define constants from the command line

# SYNOPSIS

Can use as a direct alternative to `use constant`:

```perl
    use constant::more PI    => 4 * atan2(1, 1);
    use constant:more DEBUG => 0;

    print "Pi equals ", PI, "...\n" if DEBUG;

    use constant::more {
        SEC   => 0,
        MIN   => 1,
        HOUR  => 2,
        MDAY  => 3,
        MON   => 4,
        YEAR  => 5,
        WDAY  => 6,
        YDAY  => 7,
        ISDST => 8,
    };
```

Parse arguments using [Getopt::Long](https://metacpan.org/pod/Getopt%3A%3ALong) and environment variables to set values
to constants declared in your code

```perl
    # ###
    # example.pl

    use constant::more {
            FEATURE_A_ENABLED=>{            #Name of the constant
                    value=>0,               #default value 
                    option=>"feature1",     #Getopt::Long option specification
                    env=>"MY_APP_FEATURE_A" #Environment variable copy value from 
            },

            FEATURE_B_CONFIG=>{
                    value=>"disabled",
                    option=>"feature2=s",   #Getopt::Long format
            }
    };

    
    if(FEATURE_A_ENABLED){
            #Do interesting things here
            print "Feature a is enabled
    }
    
    print "Feature b config is: ".FEATURE_B_CONFIG."\n";

    __END__

    #######

    # From command line
    perl example.pl --feature1  --feature2=active
    

    # ####
    # output

    Feature a is enabled
    Feature b config is: active
    
```

# DESCRIPTION

Performs the similar tasks as `use constant`, but adds the facility to set
the value of declared constants with values from the command line or
environment variables.

# MOTIVATION

I use the `constant` and `enum` pragma alot for unchanging values in my code.
However, I would like to have the flexibility to configure constants at program
start to enable debuging for example.

It is quite common to see something like this:

```perl
    package My::Complex::Package

    use constant DEBUG=>$ENV{"my_complex_package_debug"}//0;

    if(DEBUG){
            warn "debugging";
    }
```

This enables debug code using an evironment variable. This module implements a
similar idea but can use command line options using [GetOpt::Long](https://metacpan.org/pod/GetOpt%3A%3ALong)

# USAGE

## Simple Form

In its simplest form, defining an constant is just like the `use constant` pragma:

```perl
    use constant::more NAME=>"value";       #Set a single constant
            
    use constant::more {                    #Set multiple constants
                    NAME=>"value",
                    ANOTHER=>"one",
    };
```

## Normal Form

In its full form, an annonyous hash containing keys `val`, `opt`, `env` and
`sub` are used to setup the processing of a constant:

```perl
    use constant::more {
            MY_NAME=>{
                    val=>"john",
                    opt=>"name=s",
                    env=>"ENV_VAR_NAME",
            },
            ANOTHER=>{
                    value=>"one",
            }
    };
```

The general form of usage is showin in the Disccusion section. However here are the fine details

Constants are defined in callers name space unless name includes a package in the name
A name with '::' in it is classed as a full name for a variable. Use this to
declare constants in a common namespace (ie CONFIG for example)

Constants are only defined/set if they don't exist already.This makes
configuring constants in sub moudles possible. The module can specify a default
value, if it hasn't been been defined by the top level application. This is why
it is important to `use constant::more` at the start of your file.

Precedence of constant value is code, envrionment then command option

This means the value (default) specified in code will be only used if no
environment variable or command option is applicable.

If a command option is provided and a environment variable is available, the
command option will be used

## Advanced Form

If the child, annonymous hash contains the key `sub`, then the return list of
the the subroutine will be used as key value pairs of contant names and values
to genereate. This sub is called with a key, value pair from the default
setting, command line processing or evironment variable.

The first input argument is the name of the command line option, or undef if
default or environment variable.  The second argument is the value from the
command line option, default or environment variable.

# BUGS

# REPOSITORY

# LICENSE

# AUTHOR

# RELATED MODULES

[Getopt::constant](https://metacpan.org/pod/Getopt%3A%3Aconstant)

# COPYRIGHT