use Test;
BEGIN { plan tests => 11 }
use XML::LibXML;
ok(1);

my $dtdstr = do {
    local $/;
    open(DTD, 'example/test.dtd') || die $!;
    my $str = <DTD>;
    close DTD;
    $str;
};
ok($dtdstr);

{
# parse a DTD from a SYSTEM ID
my $dtd = XML::LibXML::Dtd->new('ignore', 'example/test.dtd');
ok($dtd);
}

{
# parse a DTD from a string
my $dtd = XML::LibXML::Dtd->parse_string($dtdstr);
ok($dtd);
}

{
# parse a DTD with a different encoding
# my $dtd = XML::LibXML::Dtd->parse_string($dtdstr, "ISO-8859-1");
# ok($dtd);
1;
}

{
# validate with the DTD
my $dtd = XML::LibXML::Dtd->parse_string($dtdstr);
ok($dtd);
my $xml = XML::LibXML->new->parse_file('example/article.xml');
ok($xml);
ok($xml->is_valid($dtd));
ok($xml->validate($dtd));
}

{
# validate a bad document
my $dtd = XML::LibXML::Dtd->parse_string($dtdstr);
ok($dtd);
my $xml = XML::LibXML->new->parse_file('example/article_bad.xml');
ok(!$xml->is_valid($dtd));
eval {
    $xml->validate($dtd);
    ok(0); # shouldn't get here
};
ok($@);
}
