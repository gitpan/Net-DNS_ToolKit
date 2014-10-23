# Before `make install' is performed this script should be runnable with
# `make test'. After `make install' it should work as `perl test.pl'

######################### We start with some black magic to print on failure.
# Change 1..1 below to 1..last_test_to_print .
# (It may become useful if the test is moved to ./t subdirectory.)

BEGIN { $| = 1; print "1..25\n"; }
END {print "not ok 1\n" unless $loaded;}

use Net::DNS::Codes qw(:all );
use Net::DNS::ToolKit qw(
	newhead
	put_qdcount
	put_ancount
	inet_aton
	inet_ntoa
	get1char
	parse_char
);
use Net::DNS::ToolKit::Debug qw(
	print_head
	print_buf
);
use Net::DNS::ToolKit::RR;

$loaded = 1;
print "ok 1\n";
######################### End of black magic.

# Insert your test code below (better if it prints "ok 13"
# (correspondingly "not ok 13") depending on the success of chunk 13
# of the test code):

$test = 2;

sub ok {
  print "ok $test\n";
  ++$test;
}

##################################################
#	first 10 test are from Question.t
#	and are just setup + a little checking
##################################################

## test 2	generate a header for a question

my $buffer = '';
my $off = newhead(\$buffer,
	12345,			# id
	QR | BITS_QUERY | RD | RA,	# query response, query, recursion desired, recursion available
);

print "bad question size $off\nnot "
	unless $off == NS_HFIXEDSZ;
&ok;

sub expect {
  my $x = shift;
  my @exp;
  foreach(split(/\n/,$x)) {
    if ($_ =~ /0x\w+\s+(\d+) /) {
      push @exp,$1;
    }
  }
  return @exp;
}

sub print_ptrs {
  foreach(@_) {
    print "$_ ";
  }
  print "\n";
}

sub chk_exp {
  my($bp,$exp) = @_;
  my @expect = expect($$exp);
  foreach(0..length($$bp) -1) {
    $char = get1char($bp,$_);
    next if $char == $expect[$_];
    print "buffer mismatch $_, got: $char, exp: $expect[$_]\nnot ";
    last;
  }
  &ok;
}

my ($get,$put,$parse) = new Net::DNS::ToolKit::RR;

## test 3	append question
# expect this from print_buf
my $exptext = q(
  0     :  0011_0000  0x30   48  0  
  1     :  0011_1001  0x39   57  9  
  2     :  1000_0001  0x81  129    
  3     :  1000_0000  0x80  128    
  4     :  0000_0000  0x00    0    
  5     :  0000_0001  0x01    1    
  6     :  0000_0000  0x00    0    
  7     :  0000_0000  0x00    0    
  8     :  0000_0000  0x00    0    
  9     :  0000_0000  0x00    0    
  10    :  0000_0000  0x00    0    
  11    :  0000_0000  0x00    0    
  12    :  0000_0011  0x03    3    
  13    :  0110_0110  0x66  102  f  
  14    :  0110_1111  0x6F  111  o  
  15    :  0110_1111  0x6F  111  o  
  16    :  0000_0011  0x03    3    
  17    :  0110_0010  0x62   98  b  
  18    :  0110_0001  0x61   97  a  
  19    :  0111_0010  0x72  114  r  
  20    :  0000_0011  0x03    3    
  21    :  0110_0011  0x63   99  c  
  22    :  0110_1111  0x6F  111  o  
  23    :  0110_1101  0x6D  109  m  
  24    :  0000_0000  0x00    0    
  25    :  0000_0000  0x00    0    
  26    :  0000_1111  0x0F   15    
  27    :  0000_0000  0x00    0    
  28    :  0000_0001  0x01    1    
);
my $name = 'foo.bar.com';
my @dnptrs;
my $type = T_MX;
my $class = C_IN;
(my $newoff,@dnptrs) = $put->Question(\$buffer,$off,$name,$type,$class);
put_qdcount(\$buffer,1);
#print_head(\$buffer);
#print_buf(\$buffer);
#print_ptrs(@dnptrs);
#print $newoff,"\n";
chk_exp(\$buffer,\$exptext);

## test 4	check offset
print "bad offset, $newoff, exp: 29\nnot "
	unless $newoff == 29;
&ok;

## test	5	get Question, check name
($newoff,$newname,$newtype,$newclass) = $get->Question(\$buffer,$off);
print "bad name, $newname, exp: $name\nnot "
	unless $newname eq $name;
&ok;

## test 6	check type
print "bad type: ",TypeTxt->{$newtype},", exp: ",TypeTxt->{$type},"\nnot "
	unless $newtype == $type;
&ok;

## test 7	check class
print "bad type: ",ClassTxt->{$newclass},", exp: ",ClassTxt->{$class},"\nnot "
	unless $newclass == $class;
&ok;

## test 8	parse record, check name .. should be pass thru
($name,$type,$class) = $parse->Question($newname,$newtype,$newclass);
print "bad name, $name, exp: $newname.\nnot "
	unless $newname.'.' eq $name;
&ok;

## test 9	check type
print "bad type: $type, exp: ",TypeTxt->{$newtype},"\nnot "
	unless $type eq TypeTxt->{$newtype};
&ok;

## test 10	check class
print "bad class: $class, exp: ",ClassTxt->{$newclass},"\nnot "
	unless $class eq ClassTxt->{$newclass};
&ok;

############ real tests follow
## test 11	autoload A.pm
$exptext = q(
  0     :  0011_0000  0x30   48  0  
  1     :  0011_1001  0x39   57  9  
  2     :  1000_0001  0x81  129    
  3     :  1000_0000  0x80  128    
  4     :  0000_0000  0x00    0    
  5     :  0000_0001  0x01    1    
  6     :  0000_0000  0x00    0    
  7     :  0011_1010  0x3A   58  :  
  8     :  0000_0000  0x00    0    
  9     :  0000_0000  0x00    0    
  10    :  0000_0000  0x00    0    
  11    :  0000_0000  0x00    0    
  12    :  0000_0011  0x03    3    
  13    :  0110_0110  0x66  102  f  
  14    :  0110_1111  0x6F  111  o  
  15    :  0110_1111  0x6F  111  o  
  16    :  0000_0011  0x03    3    
  17    :  0110_0010  0x62   98  b  
  18    :  0110_0001  0x61   97  a  
  19    :  0111_0010  0x72  114  r  
  20    :  0000_0011  0x03    3    
  21    :  0110_0011  0x63   99  c  
  22    :  0110_1111  0x6F  111  o  
  23    :  0110_1101  0x6D  109  m  
  24    :  0000_0000  0x00    0    
  25    :  0000_0000  0x00    0    
  26    :  0000_1111  0x0F   15    
  27    :  0000_0000  0x00    0    
  28    :  0000_0001  0x01    1    
  29    :  0000_0101  0x05    5    
  30    :  0110_0111  0x67  103  g  
  31    :  0110_1111  0x6F  111  o  
  32    :  0110_1111  0x6F  111  o  
  33    :  0111_0011  0x73  115  s  
  34    :  0110_0101  0x65  101  e  
  35    :  0000_0110  0x06    6    
  36    :  0110_1110  0x6E  110  n  
  37    :  0110_1111  0x6F  111  o  
  38    :  0111_0100  0x74  116  t  
  39    :  0110_0110  0x66  102  f  
  40    :  0110_1111  0x6F  111  o  
  41    :  0110_1111  0x6F  111  o  
  42    :  1100_0000  0xC0  192    
  43    :  0001_0000  0x10   16    
  44    :  0000_0000  0x00    0    
  45    :  0000_0001  0x01    1    
  46    :  0000_0000  0x00    0    
  47    :  0000_0001  0x01    1    
  48    :  0000_0000  0x00    0    
  49    :  0000_0001  0x01    1    
  50    :  0101_0001  0x51   81  Q  
  51    :  1000_0000  0x80  128    
  52    :  0000_0000  0x00    0    
  53    :  0000_0100  0x04    4    
  54    :  0000_1010  0x0A   10    
  55    :  0000_0001  0x01    1    
  56    :  0000_0010  0x02    2    
  57    :  0000_0011  0x03    3    
);
$name = 'goose.notfoo.bar.com';
my $IPaddr = '10.1.2.3';
my $netaddr = inet_aton($IPaddr);
$off = $newoff;
my $ttl = 86400;
$type = T_A;
$class = C_IN;
($newoff,@dnptrs) = $put->A(\$buffer,$off,\@dnptrs,$name,$type,$class,$ttl,$netaddr);
my $putoff = put_ancount(\$buffer,$newoff);
#print_buf(\$buffer);
#print_ptrs(@dnptrs);
chk_exp(\$buffer,\$exptext);

## test 12	check offset
print "bad offset, $newoff, exp: 58\nnot "
	unless $newoff == 58;
&ok;

## test 13	get, check offset
$newoff = 0;
($newoff,$newname,$newtype,$newclass, my $newttl, my $rdlength, my $newnetaddr) = $get->next(\$buffer,$off);
my $newIPaddr = inet_ntoa($newnetaddr);
#print "$newoff, $newname, $newtype, $newclass, $newttl, $rdlength, $newIPaddr\n";
print "bad offset, $newoff, exp: 58\nnot "
	unless $newoff == 58;
&ok;

## test 14	check name
print "bad name, $newname, exp: $name\nnot "
	unless $newname eq $name;
&ok;

## test 15	check type
print "bad type: ",TypeTxt->{$newtype},", exp: ",TypeTxt->{$type},"\nnot "
	unless $newtype == $type;
&ok;

## test 16	check class
print "bad type: ",ClassTxt->{$newclass},", exp: ",ClassTxt->{$class},"\nnot "
	unless $newclass == $class;
&ok;

## test 17	check ttl
print "bad ttl, $newttl, exp: $ttl\nnot "
	unless $newttl == $ttl;
&ok;

## test 18	check rdlength
print "bad rdlength, $rdlength, exp: 4\nnot "
	unless $rdlength == 4;
&ok;

## test 19	check IPaddr
print "bad IPaddr, $newIPaddr, exp: $IPaddr\nnot "
	unless $newIPaddr eq $IPaddr;
&ok;

## test 20	check parse, name first
$newIPaddr = '';
($name,$type,$class,$ttl,$rdlength,$newIPaddr) =
  $parse->A($newname,$newtype,$newclass,$newttl,$rdlength,$newnetaddr);
print "name does not match\ngot: $name\nexp: $newname.\nnot "
	unless $name eq $newname.'.';
&ok;

## test 21	check type
print "bad type: $type, exp: ",TypeTxt->{$newtype},"\nnot "
	unless $type eq TypeTxt->{$newtype};
&ok;

## test 22	check class
print "bad class: $class, exp: ",ClassTxt->{$newclass},"\nnot "
	unless $class eq ClassTxt->{$newclass};
&ok;

## test 23	check ttl, pass thru
print "ttl does not match, got: $ttl, exp: $newttl\nnot "
	unless $ttl == $newttl;
&ok;

## test 24	rdlength, pass thru
print "bad rdlength, $rdlength, exp: 4\nnot "
	unless $rdlength == 4;
&ok;

## test 25	check ipaddr conversion
print "bad IPaddr, got: $newIPaddr, exp: $IPaddr\nnot "
	unless $newIPaddr eq $IPaddr;
&ok;
