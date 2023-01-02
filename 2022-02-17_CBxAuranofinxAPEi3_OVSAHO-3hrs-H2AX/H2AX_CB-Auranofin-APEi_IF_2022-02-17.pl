use strict;

my $row_first = 1;

my %plate_rows = ( 
			   
			   'C' => 'cntl',
			   'D' => 'CB',
			   
                  );

my %plate_cols = ( 		   
                   1   => 'cntl',
                   2   => 'cntl',
                   3   => 'AF',
                   4   => 'AF',
                   5   => 'cntl',
                   6   => 'cntl',
                   7   => 'APEi',
                   8   => 'APEi',
                   9   => 'cntl',
                   10  => 'cntl',
                   11  => 'AF.APEi',
                   12  => 'AF.APEi'
              );
      
# leave this empty if it does not apply (H2AX staining that do not correspond to above matrix)
my %h2ax = ( );    

my $file = $ARGV[0]; # first command line input variable needs to be CSV input file name

if ( ! -e $file ) { die "ERROR: Usage $0 <filename>\n"; }

open(FILE,$file) or die "Unable to open $file\n";

# "T Id","Well Name","Nuclear Area",
#      "Wavelength 1 Integrated Nuclear Intensity","Wavelength 1 Average Nuclear Intensity",
#      "Wavelength 2 Integrated Nuclear Intensity","Wavelength 2 Average Nuclear Intensity",
#      "Wavelength 2 Integrated Cell Intensity","Wavelength 2 Average Cell Intensity",
#      "Positive Cells Integrated Intensity","Positive Cells Average Intensity","Positive Cells Area","Concentration","Group","Compound"
      

#"T Id","Well Name","Wavelength 2&3 Negative","Wavelength 2 Positive","Wavelength 3 Positive","Wavelength 2&3 Positive","Cell Area","Nuclear Area","Average Nuclear Intensity","Wavelength 2 Average Nuclear Intensity","Wavelength 2 Integrated Nuclear Intensity","Wavelength 2 Average Cytoplasm Intensity","Wavelength 2 Integrated Cytoplasm Intensity","Wavelength 2 Average Cell Intensity","Wavelength 2 Integrated Cell Intensity","Wavelength 3 Average Nuclear Intensity","Wavelength 3 Integrated Nuclear Intensity","Wavelength 3 Average Cytoplasm Intensity","Wavelength 3 Integrated Cytoplasm Intensity","Wavelength 3 Average Cell Intensity","Wavelength 3 Integrated Cell Intensity","Concentration","Group","Compound"
#1,     "A1",                              1,                      0,                      0,                        0,  65.46375,65.46375,311.2727,232.4545,5114,0,0,232.4545,5114,48,1056,0,0,48,1056,NaN,NaN,NaN


my %labels = ( #"T Id" => "time",
               #"Well Name" => "well",
               #   NOTE: @new_labels below must also be updated to match this hash!!!
               "Positive"  => 'Positive',
               "Wavelength 2&3 Negative" 				=> 'neg23count',
               "Wavelength 2 Positive"   				=> 'pos2count',
               "Wavelength 3 Positive"   				=> 'pos3count',
               "Wavelength 2&3 Positive" 				=> 'pos23count',
               "Cell Area"               				=> 'CellArea',
               "Nuclear Area"            				=> 'NucArea',
               "Average Nuclear Intensity" 				=> 'AvgNuc',
			"Wavelength 1 Average Nuclear Intensity"       => 'NucAvg1',
			"Wavelength 1 Integrated Nuclear Intensity"    => 'NucInt1',
			"Wavelength 1 Average Cytoplasm Intensity"     => 'Cyto1_Avg',
			"Wavelength 1 Integrated Cytoplasm Intensity"  => 'Cyto1_Int',
			"Wavelength 1 Average Cell Intensity"          => 'CellAvg1',
			"Wavelength 1 Integrated Cell Intensity"       => 'CellInt1',               
			"Wavelength 2 Average Nuclear Intensity"       => 'NucAvg2',
			"Wavelength 2 Integrated Nuclear Intensity"    => 'NucInt2',
			"Wavelength 2 Average Cytoplasm Intensity"     => 'Cyto2_Avg',
			"Wavelength 2 Integrated Cytoplasm Intensity"  => 'Cyto2_Int',
			"Wavelength 2 Average Cell Intensity"          => 'CellAvg2',
			"Wavelength 2 Integrated Cell Intensity"       => 'CellInt2',			
			"Wavelength 3 Average Nuclear Intensity"       => 'NucAvg3',
			"Wavelength 3 Integrated Nuclear Intensity"    => 'NucInt3',
			"Wavelength 3 Average Cytoplasm Intensity"     => 'Cyto3_Avg',
			"Wavelength 3 Integrated Cytoplasm Intensity"  => 'Cyto3_Int',
			"Wavelength 3 Average Cell Intensity"          => 'CellAvg3',
			"Wavelength 3 Integrated Cell Intensity"       => 'CellInt3',
			"Positive Cells Integrated Intensity"          => 'PositiveInt',
			"Positive Cells Average Intensity"             => 'PositiveAvg',
			"Positive Cells Area"                          => 'PositiveArea'
		);

# ordered list (hash above is not ordered) MUST UPDATE MANUALLY TO MATCH ABOVE HASH!!!
my @new_labels = ('positive','neg23count','pos2count','pos3count','pos23count',
'Cellarea','NucArea','AvgNuc','NucAvg1','NucInt1','Cyto1_Avg','Cyto1_Int','CellAvg1','CellInt1',
'NucAvg2','NucInt2','Cyto2_Avg','Cyto2_Int','CellAvg2','CellInt2',			
'NucAvg3','NucInt3','Cyto3_Avg','Cyto3_Int','CellAvg3','CellInt3',
'PositiveInt','PositiveAvg','PositiveArea');

my $first_line = <FILE>; # header line
chomp $first_line;       # remove newline
$first_line =~ s/[\'\"]//msg; # remove quotes
my @columns = split(',',$first_line);
my @current_cols;
my %current_cols; 
foreach my $entry (@columns) {
     my $new_label = $labels{$entry}; # lookup shorter name
     if ( $new_label ) { # not all incoming files will have all columns
          push(@current_cols,$new_label); # ordered list (hashes are random order)
          # $current_cols{$new_label} = 1;
     }
}
# print "condition,well,Nuc_Area,Nuc_intensity,H2AX_avg_nuc,H2AX_int_nuc,H2AX_Int_Nuc,MUTYH_Int_Cell,MUTYH_Int_Cyto,MUTYH_Int_Nuc\n";
# print to STDOUT > redirect to output file
@current_cols = ('row','column','condition','well','letter','number',@current_cols);

# Print HEADER line to output file with column names
print join(',',@current_cols) . "\n";

#"T Id","Well Name","Nuclear Area","Wavelength 1 Integrated Nuclear Intensity","Wavelength 1 Average Nuclear Intensity","Wavelength 2 Integrated Nuclear Intensity","Wavelength 2 Average Nuclear Intensity","Concentration","Group","Compound"
#1,"A1",33.92213,38117,133.7439,21354,74.92632,NaN,NaN,NaN
# print "Time,Well,NucArea,DAPI_Int,DAPI,H2AX,H2AXavg,IBR2,Olaparib,condition\n";

my $header_count = scalar(@current_cols) || 0;

while ( my $line = <FILE> ) {

     chomp $line;           # remove trailing newline
     $line =~ s/\"//g;      # remove quotes
     $line =~ s/\,NaN\,NaN\,NaN\Z//ms; # remove three trailing input file flags
     
     # 1,"A4",36.1836,25608,336.9474,1097,14.43421,1522,15.06931,1522,15.06931,48.0861,NaN,NaN,NaN
     my ($time,$well,@row) = split(",",$line);
     
     # my @row = splice(@in,0,-6);
     
     # $1 is the letter prefix (well row) and $2 is the number (well column)
     if ( !( $well =~ /(\w)(\d+)/ ) ) { 
         die "unable to match well name: $well = $line\n"; 
     }    # remove quotes
     my $letter = $1;
     my $number = $2;
     
  #if ( $letter eq 'H' && $number == 12 ) { #print STDOUT "$letter, $number\n"; }

     my $formatted_number = sprintf("%02d", $number );
     my $well_name = $letter . $formatted_number;
     
     my($row,$column);
     my $condition;
     if ( exists $h2ax{$well} ) { # create a separate group of wells for H2AX staining 
     	$row    = 'H2AX';
	     $column = $h2ax{$well};
          $condition = $row . '_' . $column; 
     } else {
     	$row    = $plate_rows{$letter} or next; # print "No plate_row for $letter!\n"  and next; # skip rows/columns that are excluded from analysis
     	$column = $plate_cols{$number} or next; # print "No plate_cols for $number!\n" and next;
          if ( $row_first ) { $condition = $row . '_' . $column; } 
                      else  { $condition = $column . '_' . $row; }
     }
     # my $condition = $row . '_' . $column;
     
     ##### other processing of hash entry data here #######
     
     # verify that all rows have the same number of entries as the header
     my @out = ($row,$column,$condition,$well_name,$letter,$number,@row);
     my $out_count = scalar(@out);
     #if ( $header_count != $out_count) { 
     #die "header= @current_cols\n\@row = @row\nheader count = $header_count, data count = $out_count for $line\n"; }
     print join(',', @out) . "\n";
  #}
}

exit;


