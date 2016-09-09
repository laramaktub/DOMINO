#!/usr/bin/perl
####################################################################
###	DOMINO: Development of molecular markers in non-model organisms 
####################################################################
# This package provides multiple subroutines for the DOMINO package 

package DOMINO;
use Data::Dumper;

sub blastn {
	my $file = $_[0]; my $db = $_[1]; my $results = $_[2]; my $BLAST = $_[3]; 
	my $filter = $BLAST."blastn -query ".$file." -evalue 1e-10 -db '".$db."' -out $results -outfmt 6";
	print "BLASTN command: $filter\n"; my $blastn = system($filter);
	return $blastn;
}

sub check_file_format {    
    my $file = $_[0];
    my $id; my $count = 3;
    my $fasta = my $fastq = my $qual = 0;
    my $format = 'unknown';
    #open(FILE, $file) or &printError("Could not open file $file") and exit(); TO FIX
    open(FILE, $file) or die "Could not open file $file";
    while (<FILE>) {
        if($count-- == 0) { last;
        } elsif(!$fasta && /^\>\S+\s*/o) { $fasta = 1; $qual = 1;
        } elsif($fasta == 1 && (/^[ACGTURYKMSWBDHVNXacgturykmswbdhvnx-]+/o)) { $fasta = 2;
        } elsif($qual == 1 && /^\s*\d+/) { $qual = 2;
        } elsif(!$fastq && /^\@(\S+)\s*/) { $id = $1; $fastq = 1;
        } elsif($fastq == 1 && (/^[ACGTURYKMSWBDHVNXacgturykmswbdhvnx-]+/o)) { $fastq = 2;
        } elsif($fastq == 2 && /^\+(\S*)\s*/o) { $fastq = 3 if($id eq $1 || /^\+\s*$/o);
    }}    
    if($fasta == 2) { $format = 'fasta';
    } elsif($qual == 2) { $format = 'qual';
    } elsif($fastq == 3) { $format = 'fastq'; }
    return $format;
}

sub dieNicely {
	print DOMINO::time_stamp();	print "\n\nTry perl $0 -man for more information\n\n";
	Pod::Usage::pod2usage( -exitstatus => 0, -verbose => 0 );
}

sub makeblastdb {
	my $file = $_[0]; my $make_blast_db = $_[1]; my $error_log = $_[2];
	my $db;
	$make_blast_db .= "makeblastdb -in ".$file;
	$make_blast_db .= " -dbtype nucl";
	if ($file =~ /(.*)\.fasta/ ) { $db = $1 ; } 
	$make_blast_db .= " -out ".$db." -logfile ".$db.".log 2> $error_log";	
	my $makeblastresult = system($make_blast_db);
	if ($makeblastresult != 0) { DOMINO::printError("Generating the database failed when trying to proccess the file... DOMINO would not stop in this step...\n"); }
	return $db;
}

sub mothur_remove_seqs {	
	# This subroutine takes as input a FASTQ file AND classifies according to the tags provided, by Roche and trims the seqs
	my $fasta = $_[0]; my $qual = $_[1]; my $directory = $_[2];
	my $ids2remove = $_[3]; my $mothur_path = $_[4];
	
	my $line = $mothur_path." '#set.dir(output=$directory); remove.seqs(accnos=$ids2remove, fasta=$fasta, qfile=$qual)'";
	print "\n+ Calling mothur executable for discarding reads...\n\n";
	my $system_call = system($line);

}

sub mothur_retrieve_seqs {
	## This sub retrieve a given number of ids and generates a fastq
	my $fasta = $_[0]; my $qual = $_[1]; my $directory = $_[2]; 
	my $ids2retrieve = $_[3]; my $mothur_path = $_[4];
	
	my $line = $mothur_path." '#set.dir(output=$directory); get.seqs(accnos=$ids2retrieve, fasta=$fasta, qfile=$qual)'";
	print "\n+ Calling mothur executable for retrieving reads in file $ids2retrieve...\n\n";
	my $system_call = system($line);
}

sub printFormat_message {
	print "\n\nPlease tag your files using: [xxx](id-)[yyy](_R[*]).fastq\nWhere:\n\txxx: any character or none.Please avoid using dots (.)\n\tid-: Optional. If xxx is too long, please provide 'id-' to identify the name provided with [yyy]\n\tyyy: is any desired name for identifying the taxa reads in these file\n\t(_R[*]): if paired end files, please tag left file using R1 and right using R2\n\n\n";
}

sub print_Header {
	my $sentence = $_[0]; my $symbol = $_[1];	
	my @length_array = ($symbol) x 97;	
	my @array_sentence = split("",$sentence);
	my $length = scalar @array_sentence;	
	my $start = 49 - ($length/2);	
	for (my $i = 0; $i < scalar @array_sentence; $i++) {
		$length_array[$start+$i] = $array_sentence[$i];
	}	
	my $string = join("", @length_array);
	print $string."\n";
}

sub print_Details {
	my $string = $_[0]; my $param_Detail_file = $_[1];
	open (PARAM, ">>$param_Detail_file");
	print PARAM $string;
	print $string;
	close(PARAM);
}

sub printError_log {
	my $message = $_[0]; my $error_log = $_[1];
	open (ERR, ">>$error_log");
	print ERR $message."\n";
	close (ERR);
}

sub print_typeInput {

print "\n\nType of input explanation:\nAccording to the type of NGS files provided several options are available but only one option would be provided: -type_input [int]
 1: A single file in Standard Flowgram Format (SFF), 454 file, containing all the reads of the different taxa accordingly tagged
 2: FASTQ files coming from 454 Roche. A single file containing all the reads of the different taxa accordingly tagged
 3: Multiple FASTQ files coming from 454 Roche. Each file contains each taxa reads. 
 4: FASTQ file from Illumina single end, containing all the reads of the different taxa accordingly tagged
 5: Multiple FASTQ file from Illumina single end. Each file contains each taxa reads. 
 6: A single pair of FASTQ files from Illumina paired-end sequencing: Each pair would contain all the reads of the different taxa accordingly tagged. 
 Please tagged left read file with xxx_R1.fastq and right read file as xxx_R2.fastq
 7: Multiple FASTQ files from Illumina paired-end: Each pair of files containing each taxa left and right reads respectively\n\n";
 
 DOMINO::printFormat_message();
 
}

sub read_dir {
	my $dir = $_[0];
	opendir(DIR, $dir) or die "ERROR: Can not open folder $dir..."; ## FIX ADD TO ERROR-LOG
	my @dir_files = readdir(DIR);
	my $array_ref = \@dir_files;
	return $array_ref;
}

sub time_stamp { return "[ ".(localtime)." ]"; }




##### TODO


sub line_splitter {
	# given a separator, splits a given line
	my $separator = $_[0];
	my @array = split($separator, $_[1]); 
	return \@array; 
}

sub get_size {
	#my $size = -s $_[0]; To get only size
	# Get lines, words and characters
	my $wc_out = `wc $_[0]`;
	$wc_out =~ s/\s/-/g;
	my $array = &splitter("\-", $wc_out);
	my @word_count;
	for (my $i=0; $i < scalar @$array; $i++) {
		if ($$array[$i] =~ /\S+/) {
			push (@word_count, $$array[$i]);			
		}
	} return \@word_count;
}

sub file_splitter {
	# Splits a file such a sam or whatever file that could be read for each line
	open (FH, "<$file") or die "Could not open source file. $!";
	print "\n\nSplitting file into blocks of $block characters...\n";
	my $j = 0; 
	while (1) {
    	my $chunk;
    	print "Processing block $j...\n";
    	my @tmp = split (".txt", $file);
		my $file_name = $tmp[0];
		
	   	my $block_file = $file_name."_part-".$j."_tmp.txt";
    	push (@files, $block_file);
    	open(OUT, ">$block_file") or die "Could not open destination file";
    	$j++;
    	if (!eof(FH)) { read(FH, $chunk,$block);  print OUT $chunk; } ## Print the amount of chars
    	if (!eof(FH)) { $chunk = <FH>; print OUT $chunk; } ## print the whole line if it is broken
    	close(OUT); last if eof(FH);
	}
	close(FH);
}

sub fasta_file_splitter {
	# Splits fasta file and takes into account to add the whole sequence if it is broken
	print "\n\nSplitting file into blocks of $block characters...\n";
	my $j = 0; my @files;
	while (1) {
		my $chunk;
		print "Processing block $j...\n";
		my $file_name; my $extension;
		if ($file =~ /(.*)\.(.*)/) {
			$file_name = $1;
			$extension = $2;
		}
		my $block_file = $file_name."_part-".$j."_tmp.".$extension;
		push (@files, $block_file);
		open(OUT, ">$block_file") or die "Could not open destination file";
		if (!eof(FH)) { read(FH, $chunk,$block);  
			if ($j > 0) {
				$chunk = ">".$chunk;
			}
			print OUT $chunk;
		} ## Print the amount of chars	
		if (!eof(FH)) { $chunk = <FH>; print OUT $chunk; } ## print the whole line if it is broken	
		if (!eof(FH)) { 
			$/ = ">"; ## Telling perl where a new line starts
			$chunk = <FH>; 
			chop $chunk;
			print OUT $chunk; 
			$/ = "\n";
		} ## print the sequence if it is broken
		$j++;
		close(OUT); last if eof(FH);
	}
	close(FH);
}

sub read_FASTA_hash {

	my $file = $_[0];
	my %hash;
	open(FILE, $file) || die "Could not open the $file ...\n";
	$/ = ">"; ## Telling perl where a new line starts
	while (<FILE>) {		
		next if /^#/ || /^\s*$/;
		chomp;
    	my ($titleline, $sequence) = split(/\n/,$_,2);
    	next unless ($sequence && $titleline);
    	$hash{$titleline} = $sequence;
	}
	close(FILE);
	$/ = "\n";
	my $hashRef = \%hash;
	return $hashRef;
}

sub seq_counter {
	
	my $file = $_[0];	
	my $option_format = DOMINO::check_file_format($file);
	my ($nSequences, $nLines);
	open (F1, "$file") or &printError("Could not open file $file") and exit(); 
	while (<F1>) { $nLines++; } close(F1);
	if ($option_format eq "fastq") { 
		$nSequences = int ($nLines/4);
	} elsif ($option_format eq "fasta") {
		$nSequences = int ($nLines/2);
	}
	return $nSequences;
}

1;