# Perl script to take the inputs of .asm file and .v testbench file.
# It will scan through the asm file and assembles it based on the instruction set architecture
# and the corresponding register set address space
# Also, it is smart enough to detect the data hazard in the application
# and adds a nop to avoid the hazard.
# nop can also be explicitely added by the user.
# The nop which are automatically added by the assembler comes with the comment added by assembler in the mem file
# Also the mem file will be created with the comments as the actual instruction that are provided
# which helps in debugging

#!/usr/bin/perl

my $asm_file = $ARGV[0];
my $tb_file = $ARGV[1];
open(DATA, $asm_file) or die "Couldn't open file file.txt, $!";
open(HEX,">test.mem") or die "Cant create";
my @lines = <DATA>;
my $previous;
my %has = (
	   # Operations
	   "nop"=>"0000","add"=>"0001",
           "addi"=>"0010","sub"=>"0011",
           "subi"=>"0100","and"=>"0101",
           "or"=>"0110","not"=>"0111",
           "mov"=>"1000","mvi"=>"1001",
           "bc"=>"1010","bs"=>"1011",
           "hlt"=>"1111",

	   # Register addresses
	   "r0"=>"0000",
           "r1"=>"0001","r2"=>"0010",
           "r3"=>"0011","r4"=>"0100",
           "r5"=>"0101","r6"=>"0110",
           "r7"=>"0111","r8"=>"1000",
           "r9"=>"1001","r10"=>"1010",
           "TMR_PWM_PPS"=>"1011","TMR_INT_PPS"=>"1100",
           "TMRCON"=>"1010","OCMP"=>"1001",
	   "TMR"=>"1000","MAXREG"=>"1011");
foreach $line (@lines)
{
 next if $line =~ /^;/;
 print "$line\n";
 if ($line =~ m/(\w+)(\s+)(\w+)(\s+)(\w+)(\s+)(\w+)/)   # or, and, add
 {
  print "First Got it with $1 $3 $5 $7\n";
  unless (exists($has{$1}) && exists($has{$3}) && exists($has{$5}) && exists($has{$7}))
  {
   die "Error!!!!!";
  }
  if($previous eq $7 || $previous eq $5)
  {
   print HEX "0000000000000000\t\//nop added by assembler\n";
  }
  print HEX "$has{$1}$has{$3}$has{$5}$has{$7}\t//$1 $3 $5 $7\n";
  $previous = $3;
 }
 elsif ( $line =~ m/(\w+)(\s+)(\w+)(\s+)0[xX]([0-9a-fA-F]+)/ )   # mvi, addi, subi
 {
  print "Second Got it with $1 $3 $5\n";
  my $bin = sprintf( "%08b", hex( "$5" ) );
  unless (exists($has{$1}) && exists($has{$3}))
  {
   die "Error!!!!!";
  }
  if($previous eq $5)
  {
   print "$previous equals $5\n";
   print HEX "0000000000000000\t\//nop added by assembler\n";
  }
  print HEX "$has{$1}$has{$3}$bin\t\//$1 $3 $5\n";
  $previous = $3;
 }
 elsif ( $line =~ m/(\w+)(\s+)(\w+)(\s+)(\d+)/ )   # bc, bs
 {
  print "Third Got it with $1 $3 $5\n";
  my $bin = sprintf( "%08b", 2 ** $5 );
  unless (exists($has{$1}) && exists($has{$3}))
  {
   die "Error!!!!!";
  }
  if($previous eq $5)
  {
   print HEX "0000000000000000\t\//nop added by assembler\n";
  }
  print HEX "$has{$1}$has{$3}$bin\t\//$1 $3 $5\n";
  $previous = $3;
 }
 elsif ( $line =~ m/(\w+)(\s+)(\w+)(\s+)(\w+)/ )   # mov, not
 {
  print "Fourth Got it with $1 $3 $5\n";
  unless (exists($has{$1}) && exists($has{$3}) && exists($has{$5}))
  {
   die "Error!!!!!";
  }
  if($previous eq $5)
  {
   print HEX "0000000000000000\t\//nop added by assembler\n";
  }
  print HEX "$has{$1}$has{$3}$has{$5}0000\t\//$1 $3 $5\n";
  $previous = $3;
 }
 elsif ( $line =~ m/(\w+)/ )   # hlt, nop
 {
  print "Fourth Got it with $1\n";
  unless (exists($has{$1}))
  {
   die "Error!!!!!";
  }
  $previous = $1;
  print HEX "$has{$1}000000000000\t\//$1\n";
 }
 else
 {
  print "Syntax error!!!";
 }
}

system "vcs -Mupdate -debug_all -f files.f $tb_file";
