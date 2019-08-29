#!/usr/bin/perl
use strict;
use warnings;
use JSON;
use Data::Dumper;
use Getopt::Long;
use Time::Piece;

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
    my $filename_log = "awstats";
    my $filename;

    #default awstats
    #my $command = "/usr/bin/awstats -update -lang=$lang -config=/etc/awstats/awstats.$domain > /dev/null";
    my $currentyear = localtime->strftime('%Y');
    my $currentmonth = localtime->strftime('%m');
    $currentyear =~ s/^\s*|\s*$//g;
    $currentmonth =~ s/^\s*|\s*$//g;

    #month
    if($month ne '') {
       #$command = $command." -month=$month";
       $filename_log = $filename_log.$month;
    }

    if ($month eq '') {
        $filename_log = $filename_log.$currentmonth;
    }
    #year
    if($year ne '') {
      #$command = $command." -year=$year";
      $filename_log = $filename_log.$year; 
    } 
    if ($year eq '') {
        $filename_log = $filename_log.$currentyear;
    }
    $filename_log = "$filename_log.txt";
    $filename = "/var/lib/awstats/".$domain."/".$filename_log;
    #system("$command");    
    my $json = JSON->new;
    my $myadd;
    my $data_to_json;
    my @fulljson;
    open (FILE, $filename) or die "Could not open $filename: $!";
    my $jsonstring;
    while( my $line = <FILE> )  {

       #FIND OPEN TAG
       if ($line=~m/^BEGIN/) {
           my ($key, $value) = split /\s+/, $line, 2;
           $value=~ s/^\s*|\s*$//g;      
           $data_to_json={ftag=>$key,fvalue=>$value};
           $myadd = $json->encode($data_to_json);
           #print "myadd posle dobavleniya $myadd\n";           
       } elsif ($line=~m/^END/) {     
           #FIND END TAG
           my ($key, $value) = split /\s+/, $line, 2;
           $value=~ s/^\s*|\s*$//g;
           #decoding
           my $und = decode_json($myadd);
           foreach my $key(keys %$und) {
               if ( $key eq "ftag" ) {                  
                  #dobavlenie novogo klyuacha 
                  my ($key_, $val_) = ('Key', $value);
                  $und->{'endtag'} = 1;
                  $myadd = encode_json($und);
                  push @fulljson, {%$und};
                  $myadd="";   
               }
           }
       }

       else {
               my $frombegin = $myadd;
               unless ($frombegin) {
                  #NE NAYDEN NACHALNIY TAG - NE MOGU DOBAVLYAT
               }  else {
                    #NAYDEN NACHALNIY TAG
                    my ($key, $value) = split /\s+/, $line , 2;
                    $value =~ s/^\s*|\s*$//g;
                    my $und = decode_json($myadd);
                    $und->{$key} = $value;
                    $myadd = encode_json($und);
              }
       } 
   }
   print encode_json(\@fulljson)."\n";
   close (FILE);
}
