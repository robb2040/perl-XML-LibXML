#!/usr/bin/perl

=head1 ABOUT

Minimal example of creating an HTML document using XML::LibXML's DOM
routines, without any subroutines.  Outputs a single line of content:
"Hello world....您好。"

Written to resolve L<https://github.com/cpan-authors/XML-LibXML/issues/66>.

=cut

use strict;
use warnings;

use XML::LibXML;

my $doc  = XML::LibXML->createDocument;
my $html = $doc->createElement('html');
my $body = $doc->createElement('body');
my $p    = $doc->createElement('p');

$p->appendText("Hello world....您好。");
$body->appendChild($p);
$html->appendChild($body);
$doc->setDocumentElement($html);
$doc->createInternalSubset( "html", (undef) x 2 );

print $doc->toStringHTML();

=head1 COPYRIGHT & LICENSE

Copyright 2016 by Shlomi Fish

This program is distributed under the MIT (X11) License:
L<http://www.opensource.org/licenses/mit-license.php>

Permission is hereby granted, free of charge, to any person
obtaining a copy of this software and associated documentation
files (the "Software"), to deal in the Software without
restriction, including without limitation the rights to use,
copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the
Software is furnished to do so, subject to the following
conditions:

The above copyright notice and this permission notice shall be
included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
OTHER DEALINGS IN THE SOFTWARE.

=cut
