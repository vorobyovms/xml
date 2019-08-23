#!/usr/bin/perl
use strict;
use warnings;
use JSON;
use JSON qw( decode_json );
use Data::Dumper;
use String::Util qw(trim);

#datefirsrt datesecond
#ubrat perenos stroki
my($filename) = @ARGV;
print("Filename enter = '$filename'");
#my finalrray[];

if (defined $filename) {
    my $filels=`/bin/ls -l /var/lib/awstats/ | /bin/grep txt | /usr/bin/awk '{print $9}'`;
    print "files in directory /var/lib/awstat $filels\n";
    my $json = JSON->new;
    my $myadd;
    my $data_to_json;
    my @fulljson;
    #print "Vi vveli file\n -- VSE OK\n";
    #print "Formiruem seychas JSON Structuru sootvestvenno LOG file '$filename'\n";
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
       } else {
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
} else {
    print "Vi ne vveli file\n";
}

