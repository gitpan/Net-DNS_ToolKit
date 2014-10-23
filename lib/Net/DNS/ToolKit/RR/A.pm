package Net::DNS::ToolKit::RR::A;

#use 5.006;
use strict;
#use warnings;

use vars qw($VERSION @ISA);
require Net::DNS::ToolKit::RR::Template;

$VERSION = do { my @r = (q$Revision: 0.02 $ =~ /\d+/g); sprintf "%d."."%02d" x $#r, @r };

@ISA = qw(Net::DNS::ToolKit::RR::Template);

*get	= \&Net::DNS::ToolKit::RR::Template::get;
*put	= \&Net::DNS::ToolKit::RR::Template::put;
*parse	= \&Net::DNS::ToolKit::RR::Template::parse;

=cut

1;
__END__

=head1 NAME

Net::DNS::ToolKit::RR::A - Resource Record Handler

=head1 SYNOPSIS

  DO NOT use Net::DNS::ToolKit::RR::A
  DO NOT require Net::DNS::ToolKit::RR::A

  Net::DNS::ToolKit::RR::A is autoloaded by 
  class Net::DNS::ToolKit::RR and its methods
  are instantiated in a 'special' manner.

  use Net::DNS::ToolKit::RR;
  ($get,$put,$parse) = new Net::DNS::ToolKit::RR;

  ($newoff,$name,$type,$class,$ttl,$rdlength,
	$netaddr) = $get->A(\$buffer,$offset);

  Note: the $get->A method is normally called
  via:	@stuff = $get->next(\$buffer,$offset);

  ($newoff,@dnptrs)=$put->A(\$buffer,$offset,\@dnptrs,
        $name,$type,$class,$ttl,$netaddr);

  $name,$TYPE,$CLASS,$TTL,$rdlength,$IPaddr) 
    = $parse->A($name,$type,$class,$ttl,$rdlength,
	$netaddr);

=head1 DESCRIPTION

B<Net::DNS::ToolKit::RR:A> appends an A resource record to a DNS packet under
construction, recovers an A resource record from a packet being decoded, and 
converts the numeric/binary portions of the resource record to human
readable form.

  Description from RFC1035.txt

  3.2.1. Format

  All RRs have the same top level format shown below:

                                    1  1  1  1  1  1
      0  1  2  3  4  5  6  7  8  9  0  1  2  3  4  5
    +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
    |                      NAME                     |
    +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
    |                      TYPE                     |
    +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
    |                     CLASS                     |
    +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
    |                      TTL                      |
    +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
    |                   RDLENGTH                    |
    +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--|
    |                     RDATA                     |
    +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+

  NAME	an owner name, i.e., the name of the node to which this
	resource record pertains.

  TYPE	two octets containing one of the RR TYPE codes.

  CLASS	two octets containing one of the RR CLASS codes.

  TTL	a 32 bit signed integer that specifies the time interval
	that the resource record may be cached before the source
	of the information should again be consulted.  Zero
	values are interpreted to mean that the RR can only be
	used for the transaction in progress, and should not be
	cached.  For example, SOA records are always distributed
	with a zero TTL to prohibit caching.  Zero values can
	also be used for extremely volatile data.

  RDLENGTH an unsigned 16 bit integer that specifies the length
	in octets of the RDATA field.

  RDATA	a variable length string of octets that describes the
	resource.  The format of this information varies
	according to the TYPE and CLASS of the resource record.

  3.4.1. A RDATA format

    +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
    |                    ADDRESS                    |
    +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+

  where:

  ADDRESS         A 32 bit Internet address.

Hosts that have multiple Internet addresses will have multiple A
records.

=over 4

=item * @stuff = $get->A(\$buffer,$offset);

  Get the contents of the resource record.

  USE: @stuff = $get->next(\$buffer,$offset);

  where: @stuff = (
  $newoff $name,$type,$class,$ttl,$rdlength,
  $netaddr );

All except the last item, B<$netaddr>, is provided by
the class loader, B<Net::DNS::ToolKit::RR>. The code in this method knows
how to retrieve B<$netaddr>.

  input:	pointer to buffer,
		offset into buffer
  returns:	offset to next resource,
		@common RR elements,
		packed IPv4 address 
		  in network order

  NOTE:	convert IPv4 address to dot quad text
	using Net::DNS::ToolKit::inet_ntoa

=item * ($newoff,@dnptrs)=$put->A(\$buffer,$offset,\@dnptrs,  
	@common,$netaddr);  

Append an A record to $buffer.

  where @common = $name,$type,$class,$ttl

The B<A> method will insert the $rdlength and $netaddr, then
pass through the updated pointer to the array of compressed names

The class loader, B<Net::DNS::ToolKit::RR>, inserts the @common elements and
returns updated @dnptrs. This module knows how to insert its RDATA and calculate the $rdlength.

  input:	pointer to buffer,
		offset (normally end of buffer),
		pointer to compressed name array,
		@common RR elements,
		packed IPv4 address
		  in network order
  output:	offset to next RR,
		new compressed name pointer array,
	   or	empty list () on error.

  NOTE:	convert dot quad text to a packed network
	address using Net::DNS::ToolKit::inet_aton

=item * (@COMMON,$RDATA) = $parse->A(@common,$rdata,...);

Converts binary/numeric field data into human readable form. The common RR
elements are supplied by the class loader, B<Net::DNS::ToolKit::RR>. This
module knows how to parse its RDATA.

	EXAMPLE
Common is: name,$type,$class,$ttl,$rdlength

  name       is already text.
  type       numeric to text
  class      numeric to text
  ttl        numeric to text
  rdlength   is a number
  rdata      RR specific conversion

Resource Record B<A> returns $rdata containing a packed IPv4 network
address. The parse operation would be:

input:

  name       foo.bar.com
  type       1  
  class      1  
  ttl        123
  rdlength   4
  rdata      a packed IPv4 address

output:

  name       foo.bar.com
  type       T_A 
  class      C_IN
  ttl        123 # 2m 3s
  rdlength   4
  rdata      192.168.20.40

=back

=head1 DEPENDENCIES

	Net::DNS::ToolKit
	Net::DNS::ToolKit::RR::Template
	Net::DNS::Codes

=head1 EXPORT

	none

=head1 AUTHOR

Michael Robinton <michael@bizsystems.com>

=head1 COPYRIGHT

    Copyright 2003, Michael Robinton <michael@bizsystems.com>
   
    This program is free software; you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation; either version 2 of the License, or
    (at your option) any later version.
   
    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.
   
    You should have received a copy of the GNU General Public License
    along with this program; if not, write to the Free Software
    Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA 02111-1307, USA.

=head1 See also:

Net::DNS::Codes(3), Net::DNS::ToolKit(3), Net::DNS::ToolKit::RR::Template(3)

=cut

1;
