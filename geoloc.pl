#!/usr/bin/perl

###########################################################################
# geoloc.pl - extracts environmental data from agrimetrics API
###########################################################################

use strict;
use warnings;
use List::Util qw(sum);
use Data::GUID;
use DBI;
use DBD::mysql;
use Excel::Writer::XLSX;
use File::Temp;
use Scalar::MoreUtils qw(empty);
use CGI;
use List::MoreUtils qw( mesh );
use JSON;
use JSON qw( decode_json );
use Data::Dumper;


    local ($buffer, @pairs, $pair, $name, $value, %FORM);
    # Read in text
    $ENV{'REQUEST_METHOD'} =~ tr/a-z/A-Z/;
    if ($ENV{'REQUEST_METHOD'} eq "POST")
    {
        read(STDIN, $buffer, $ENV{'CONTENT_LENGTH'});
    }else {
        $buffer = $ENV{'QUERY_STRING'};
    }
    ############## Split information into name/value pairs
    @pairs = split(/&/, $buffer);
    foreach $pair (@pairs)
    {
        ($name, $value) = split(/=/, $pair);
        $value =~ tr/+/ /;
        $value =~ s/%(..)/pack("C", hex($1))/eg;
        $FORM{$name} = $value;
    }
    $text_content = $FORM{long};
	

        ######################remove any blank lines from input
        $text_content =~ s/^\s*\n+//mg ;
        chomp $text_content;

        ### remove windows new line #########
        $text_content =~ s/\r\n\z//;

        ### remove spaces #########
#        $text_content =~ s/\s/_/g;


    $text_content2 = $FORM{lat};


        ######################remove any blank lines from input
        $text_content2 =~ s/^\s*\n+//mg ;
        chomp $text_content2;

        ### remove windows new line #########
        $text_content2 =~ s/\r\n\z//;

print "Content-type:text/html\r\n\r\n";

print "<style>";
print "table, th, td {";
print "  border: 1px solid black;";
print "}";
print "</style>";

print "<H1><b>Agrigem geoloc results:</b><\/H1>";
print "<p><b>Longitude = </b>$text_content<p><b>Latitude = </b>$text_content2<p>";

my $curl = "curl -X GET 'https://api.agrimetrics.co.uk/field-search/v1/?\$filter=geo.distance%28Field/centroid,%20geography%27SRID=4326;Point%28".$text_content."%20".$text_content2."%29%27%29%20lt%201500'  -H 'Ocp-Apim-Subscription-Key: cd5723ce041a46cc9048ed8a8a74f8fc'";

my $result = `$curl`;

### Bad parsing of field id below - given more time we would do this with a regex!!
my ($first, $last)  = split(/}/, $result,2);
my ($grab1, $grab2) = split(/,/, $first, 2);
my $line = (split '/', $grab1)[-1];
$line = substr($line, 0, -1); 


print "<b>Field id=</b>".$line."<p>";
print "<p><H1>Average Monthly Temperature</H1><p>";
my $curl2 = "curl -X GET 'https://api.agrimetrics.co.uk/field-facts/v1/".$line."' -H 'Ocp-Apim-Subscription-Key: cd5723ce041a46cc9048ed8a8a74f8fc'";
my $result2 = `$curl2`;

### Decode JSON response ###
my $decoded = decode_json($result2);

my $temp = $decoded->{hasLongTermAverageMonthlyMeanTemperature}{hasDatapoint};

for my $point (@$temp){
	print "<p>Value:$point->{value}\t Month:$point->{month}\n";

}

foreach my $f ( @friends ) {
	warn "aaa";
  print Dumper $f->{hasDatapoint};
}

