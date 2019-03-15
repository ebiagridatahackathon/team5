#!/usr/bin/perl

###########################################################################
# agrigem.pl  Queries agrigem database and displays data
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
    $text_content = $FORM{location};
	

        ######################remove any blank lines from input
        $text_content =~ s/^\s*\n+//mg ;
        chomp $text_content;

        ### remove windows new line #########
        $text_content =~ s/\r\n\z//;


    $text_content2 = $FORM{soil};


        ######################remove any blank lines from input
        $text_content2 =~ s/^\s*\n+//mg ;
        chomp $text_content2;

        ### remove windows new line #########
        $text_content2 =~ s/\r\n\z//;

    $text_content3 = $FORM{yield};


        ######################remove any blank lines from input
        $text_content3 =~ s/^\s*\n+//mg ;
        chomp $text_content3;

        ### remove windows new line #########
        $text_content3 =~ s/\r\n\z//;



print "Content-type:text/html\r\n\r\n";

print "<style>";
print "table, th, td {";
print "  border: 1px solid black;";
print "}";
print "</style>";

print "<H1><b>Agrigem results:</b><\/H1>";
print "<p>Location = $text_content<p>Soil type =$text_content2<p> Yield >= $text_content3<p>";

#my $SQL = "Select  QTL_name , chr, population, LOD, start_marker, Cistart_bp, end_marker, Ciend_bp  from QTL where longtraitnames  like '%".$text_content."%'";

my $SQL = "Select Farmer_id, Field_id, County, Previouscrop, Soil_class, species, Variety, yield, Height, grain_prot, Geoloc_lat, Geoloc_long, year from main where County like '".$text_content."' and Soil_class like '%".$text_content2."%' and yield>=".$text_content3." and Geoloc_long >0 ";

	#### Search QTL data ###
	my $dsn = "DBI:mysql:agrigem:localhost";
	my $user_name = "root";
	my $password = "your_db_password";

	# Connect to database
	$dbh = DBI->connect ($dsn, $user_name, $password, {PrintError => 1});

	$sth = $dbh->prepare ($SQL);

	# Execute the prepared statement handle:
	$sth->execute ();

print "<table>";
## Table header
print "<table style=\"max-width: 1050px;\"><thead><tr><th>Farmer</th><th>Field</th><th>County</th><th>Previous crop</th><th>Soil</th><th>species</th><th>Variety</th><th>Yield</th><th>Height</th><th>Protein</th><th>Latitude</th><th>Longitude</th><th>Year</th><th>Link</th></tr></thead>";
        while ($row = $sth->fetchrow_arrayref()) {


        print "<tr><td>@$row[0]</td><td>@$row[1]</td><td>@$row[2]</td><td>@$row[3]</td><td>@$row[4]</td><td>@$row[5]</td><td><a href=\"http://www.cerealsdb.uk.net/cerealgenomics/cgi-bin/select_genotypes.pl?example=35&var=".@$row[6]."&chrom0=1A&chrom1=1B&chrom2=1D&chrom3=2A&chrom4=2B&chrom5=2D&chrom6=3A&chrom7=3B&chrom8=3D&chrom9=4A&chrom10=4B&chrom11=4D&chrom12=5A&chrom13=5B&chrom14=5D&chrom15=6A&chrom16=6B&chrom17=6D&chrom18=7A&chrom19=7B&chrom20=7D&submitter=Submit+Button\">@$row[6]</a></td><td>@$row[7]</td><td>@$row[8]</td><td>@$row[9]</td><td>@$row[10]</td><td>@$row[11]</td><td>@$row[12]</td><td><a href=\"http://www.cerealsdb.uk.net/cerealgenomics/cgi-bin/geoloc.pl?long=".@$row[11]."&lat=".@$row[10]."\">Here</td></tr>";
        #print "</table>";
}

print "</table>";

my $curl = "curl -X GET 'https://api.agrimetrics.co.uk/field-search/v1/?\$filter=geo.distance%28Field/centroid,%20geography%27SRID=4326;Point%280.64209514%2051.843501%29%27%29%20lt%201500'  -H 'Ocp-Apim-Subscription-Key: cd5723ce041a46cc9048ed8a8a74f8fc'";

### System call to run curl and put output into a variable called $result ####
my $result = `$curl`;

print "<p>RESULT=".$result."<p>";

