#!/usr/bin/perl
use strict;
use warnings;
use JSON;
use Data::Dumper;
use String::Util qw(trim);
use Getopt::Long;

#datefirsrt datesecond
#ubrat perenos stroki

my $month = '';
my $year = '';
my $lang = 'en';
my $domain = '';

GetOptions (
    'month=s' => \$month,
    'year=s' => \$year,
    'lang=s' => \$lang,
    'domain=s' => \$domain
) or die ('Error in arguments');

if ($domain eq '') {
     die "Domain is required";
} else {
    print "domain = $domain\n";
}


#my finalrray[];

if (defined $lang && defined $year && defined $month && defined $domain) {

    my $curdatefull = `/bin/date +'%Y-%m-%d-%S'`;
    my $filename_log = "awstats".$month.$year.".txt";
    my $filename = "/var/lib/awstats/".$domain."/".$filename_log;
    print "full log = $filename\n";
    print "cur date full = $curdatefull\n";

    my $resexists = system("ls -l /var/lib/awstats/$domain/ | grep $filename_log | awk '{print \$9}'");
    print "resexists = $resexists\n";
    if ( $resexists eq "" ) {
        print "File ne suhestvuet\n";
        #system("touch $filename");
    }
    if( $resexists ne "" ) {
         print "File suhestvuet\n";
    }

    #my $command = "/usr/bin/awstats -update -month=$month -year=$year -lang=$lang -config=/etc/awstats/awstats.$domain > $filename";
    my $command = "/usr/bin/awstats -update -month=$month -year=$year -lang=$lang -config=/etc/awstats/awstats.$domain > /dev/null";
    #my $command = "/usr/bin/awstats -config=/etc/awstats/awstats.$domain";
    print "command = $command\n";

    system("$command");    
    my $json = JSON->new;
    my $myadd;
    my $data_to_json;
    my @fulljson;
    #print "Vi vveli file\n -- VSE OK\n";
    #print "Formiruem seychas JSON Structuru sootvestvenno LOG file '$filename'\n";
    #system("touch $filename");
    open (FILE, $filename) or die "Could not open $filename: $!";
    #print "filename=$filename\n";
    my $jsonstring;
    while( my $line = <FILE> )  {

       #FIND OPEN TAG
       if ($line=~m/^BEGIN/) {
           #print "sovpalo BEGIN $line\n";
           my ($key, $value) = split /\s+/, $line, 2;
           $value= trim( $value );      
           $data_to_json={ftag=>$key,fvalue=>$value};
           $myadd = $json->encode($data_to_json);
           #print "myadd posle dobavleniya $myadd\n";           
       } elsif ($line=~m/^END/) {     
           #FIND END TAG
           #print " 'sovpalo END $line\n";
           my ($key, $value) = split /\s+/, $line, 2;
           $value= trim( $value );
           #decoding
           my $und = decode_json($myadd);
           #print "undecode = $und \n"; 
           foreach my $key(keys %$und) {
               #print "key = $key\n";
               if ( $key eq "ftag" ) {                  
                  #dobavlenie novogo klyuacha
                  #print "value pered dobavleniem = $value \n"; 
                  my ($key_, $val_) = ('Key', $value);
                  $und->{'endtag'} = 1;
                  $myadd = encode_json($und);
                  #print "myadd after add = $myadd\n";
                  push @fulljson, {%$und};
                  #push @fulljson, $myadd;
		  #obnulenie
                  $myadd="";   
               }
           }
       } 

       else {
	       #print "NE BEGIN NE END\n";
               #print "myadd = $myadd\n";
               my $frombegin = $myadd;
               #print "frombegin = $frombegin\n";
               
	       unless ($frombegin) {
		  #print "NE NAYDEN NACHALNIY TAG - NE MOGU DOBAVLYAT - $line\n";
	       }  else {
                    #print "NAYDEN NACHALNIY TAG";
                    my ($key, $value) = split /\s+/, $line , 2;
                    $value = trim( $value );
                    my $und = decode_json($myadd);
                    $und->{$key} = $value;
                    $myadd = encode_json($und);
              }
       }

       #print Dumper(@fulljson)."\n";
       #print @fulljson."\n";
       #print $json->encode($data_to_json) . "\n";
       #list all array
       #foreach my $mline (@fulljson) {
       #   print $mline->{'ftag'}."\n";
       #}
   }
   #print Dumper(@fulljson)."\n";
   print encode_json(\@fulljson)."\n";
   close (FILE);
} 

#-----------------------------------------------------------------------------------------
if (defined $lang && defined $domain && !defined $month && !defined $year) {
      my $curdatefull = `/bin/date +'%Y-%m-%d-%S'`;
      my $filename_log = "awstats".$month.$year.".txt";
      my $filename = "/var/lib/awstats/".$domain."/".$filename_log;
      print "full log = $filename\n";
      print "cur date full = $curdatefull\n";

      my $resexists = system("ls -l /var/lib/awstats/$domain/ | grep $filename_log | awk '{print \$9}'");
      print "resexists = $resexists\n";
      if ( $resexists eq "" ) {
        print "File ne suhestvuet\n";
        #system("touch $filename");
      }
      if( $resexists ne "" ) {
         print "File suhestvuet\n";
      }

      #my $command = "/usr/bin/awstats -update -month=$month -year=$year -lang=$lang -config=/etc/awstats/awstats.$domain > $filename";
      my $command = "/usr/bin/awstats -update -lang=$lang -config=/etc/awstats/awstats.$domain > /dev/null";
      #my $command = "/usr/bin/awstats -config=/etc/awstats/awstats.$domain";
      print "command = $command\n";

      system("$command");
      my $json = JSON->new;
      my $myadd;
      my $data_to_json;
      my @fulljson;
      #print "Vi vveli file\n -- VSE OK\n";
      #print "Formiruem seychas JSON Structuru sootvestvenno LOG file '$filename'\n";
      #system("touch $filename");
      open (FILE, $filename) or die "Could not open $filename: $!";
      #print "filename=$filename\n";
      my $jsonstring;     
}

#---------------------------------------------------------------------------------------------------
if (!defined $lang && defined $domain && !defined $month && !defined $year) {
      my $curdatefull = `/bin/date +'%Y-%m-%d-%S'`;
      my $filename_log = "awstats".$month.$year.".txt";
      my $filename = "/var/lib/awstats/".$domain."/".$filename_log;
      print "full log = $filename\n";
      print "cur date full = $curdatefull\n";

      my $resexists = system("ls -l /var/lib/awstats/$domain/ | grep $filename_log | awk '{print \$9}'");
      print "resexists = $resexists\n";
      if ( $resexists eq "" ) {
        print "File ne suhestvuet\n";
        #system("touch $filename");
      }
      if( $resexists ne "" ) {
         print "File suhestvuet\n";
      }

      #my $command = "/usr/bin/awstats -update -month=$month -year=$year -lang=$lang -config=/etc/awstats/awstats.$domain > $filename";
      my $command = "/usr/bin/awstats -update -config=/etc/awstats/awstats.$domain > /dev/null";
      #my $command = "/usr/bin/awstats -config=/etc/awstats/awstats.$domain";
      print "command = $command\n";

      system("$command");
      my $json = JSON->new;
      my $myadd;
      my $data_to_json;
      my @fulljson;
      #print "Vi vveli file\n -- VSE OK\n";
      #print "Formiruem seychas JSON Structuru sootvestvenno LOG file '$filename'\n";
      #system("touch $filename");
      open (FILE, $filename) or die "Could not open $filename: $!";
      #print "filename=$filename\n";
      my $jsonstring;   
}

#----------------------------------------------------------------------------------------------------------------------
else {
    print "Vi ne vveli obyazatelnie parametri\n";
}


