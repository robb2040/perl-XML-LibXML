use strict;
use warnings;

use Test::More;
use XML::LibXML;

if (XML::LibXML::LIBXML_VERSION() < 20627) {
    plan skip_all => "skipping for libxml2 < 2.6.27";
}
else {
    plan tests => 5;
}

my @loader_urls;

sub tracking_loader {
    push @loader_urls, $_[0];
    return "ENTITY_CONTENT";
}

# Set global entity loader
XML::LibXML::externalEntityLoader(\&tracking_loader);

# TEST
# Sanity: global loader works for non-network entities
{
    @loader_urls = ();
    my $parser = XML::LibXML->new({
        expand_entities => 1,
        load_ext_dtd => 1,
    });
    my $xml = <<'EOF';
<?xml version="1.0"?>
<!DOCTYPE foo [
<!ENTITY a SYSTEM "file:///dev/null">
]>
<root>&a;</root>
EOF
    my $doc = eval { $parser->parse_string($xml) };
    ok(defined $doc, "Global loader works for non-network entities");
}

# TEST
# no_network must block HTTP entities even when global loader is set
{
    @loader_urls = ();
    my $parser = XML::LibXML->new({
        expand_entities => 1,
        no_network => 1,
        load_ext_dtd => 1,
    });
    my $xml = <<'EOF';
<?xml version="1.0"?>
<!DOCTYPE foo [
<!ENTITY a SYSTEM "http://example.com/entity.xml">
]>
<root>&a;</root>
EOF
    my $doc = eval { $parser->parse_string($xml) };
    my @net_calls = grep { /^https?:|^ftp:/ } @loader_urls;
    is(scalar @net_calls, 0,
       "no_network prevents global entity loader from receiving HTTP URLs");
}

# TEST
# no_network must block HTTPS entities even when global loader is set
{
    @loader_urls = ();
    my $parser = XML::LibXML->new({
        expand_entities => 1,
        no_network => 1,
        load_ext_dtd => 1,
    });
    my $xml = <<'EOF';
<?xml version="1.0"?>
<!DOCTYPE foo [
<!ENTITY a SYSTEM "https://example.com/entity.xml">
]>
<root>&a;</root>
EOF
    my $doc = eval { $parser->parse_string($xml) };
    my @net_calls = grep { /^https?:|^ftp:/ } @loader_urls;
    is(scalar @net_calls, 0,
       "no_network prevents global entity loader from receiving HTTPS URLs");
}

# TEST
# no_network must block FTP entities even when global loader is set
{
    @loader_urls = ();
    my $parser = XML::LibXML->new({
        expand_entities => 1,
        no_network => 1,
        load_ext_dtd => 1,
    });
    my $xml = <<'EOF';
<?xml version="1.0"?>
<!DOCTYPE foo [
<!ENTITY a SYSTEM "ftp://example.com/entity.xml">
]>
<root>&a;</root>
EOF
    my $doc = eval { $parser->parse_string($xml) };
    my @net_calls = grep { /^https?:|^ftp:/ } @loader_urls;
    is(scalar @net_calls, 0,
       "no_network prevents global entity loader from receiving FTP URLs");
}

# TEST
# Without no_network, global loader should still receive network URLs
{
    @loader_urls = ();
    my $parser = XML::LibXML->new({
        expand_entities => 1,
        load_ext_dtd => 1,
    });
    my $xml = <<'EOF';
<?xml version="1.0"?>
<!DOCTYPE foo [
<!ENTITY a SYSTEM "http://example.com/entity.xml">
]>
<root>&a;</root>
EOF
    my $doc = eval { $parser->parse_string($xml) };
    my @net_calls = grep { /^https?:/ } @loader_urls;
    ok(scalar @net_calls > 0,
       "Without no_network, global loader receives network URLs normally");
}
