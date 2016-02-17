#!/usr/bin/env perl

use Catmandu::Sane;
use Catmandu;
use Catmandu::Exporter::JSON;
use Moo;
use MooX::Options;
use XML::Writer;
use XML::Simple;
use Try::Tiny;
use LWP::UserAgent;

option verbose => (
    is => 'ro',
    short => 'v',
    doc => "Print details.",
    );
option file => (
    is => 'ro',
    format => 's',
    default => sub {'ut.csv'},
    doc => "Specify the input file, default is 'ut.csv' in the pwd.",
    );
option dry => (
    is => 'ro',
    doc => 'Dry run option.'
);

Catmandu->load;

#my $exporter = Catmandu::Exporter::JSON->new(file => 'wos_citations.json');

sub _generate_xml {
    my ($self, @data) = @_;

    my $xml = XML::Writer->new(OUTPUT => 'self', ENCODING => 'UTF-8');
    $xml->xmlDecl;
    $xml->startTag('request', 'xmlns' => 'http://www.isinet.com/xrpc41');

    $xml->startTag('fn', 'name' => 'LinksAMR.retrieve');
    $xml->startTag('list');
    $xml->emptyTag('map');

    $xml->startTag('map');
    $xml->startTag('list', 'name' => 'WOS');
    $xml->dataElement('val', 'timesCited');
    $xml->dataElement('val', 'citingArticlesURL');
    $xml->dataElement('val', 'ut');
    $xml->dataElement('val', 'doi');
    $xml->dataElement('val', 'doi');
    $xml->endTag('list');
    $xml->endTag('map');

    $xml->startTag('map');

    foreach my $d (@data) {
        $xml->startTag('map', 'name' => $d->{_id});
        foreach my $f (qw(ut doi pmid)) {
            if ($d->{$f}) {
                $xml->dataElement('val', $d->{$f}, 'name' => $f);
                last;
            }
        }
        $xml->endTag('map');
    }

    $xml->endTag('map');

    $xml->endTag('list');
    $xml->endTag('fn');
    $xml->endTag('request');

    return $xml->to_string();
}

sub _do_request {
    my ($self, $content) = @_;

    my $ua = LWP::UserAgent->new;
    my $response = $ua->post(
        'http://ws.isiknowledge.com/cps/xrpc',
        Content => $content,
        );

    $response->is_success ? return $response->{_content} : return 0;
}

sub _parse_xml {
    my ($self, $xml) = @_;

    return unless $xml;
    my $hash;
    try {
        $hash = XMLin($xml);

        return if exists $hash->{error};
        my $items = $hash->{fn}->{map}->{map};

        foreach my $id (keys %$items) {
            next if ref $items ne 'HASH';

            my $tmp = $items->{$id}->{map}->{val};
            my $data = {
                _id => $id,
                ut => $tmp->{ut}->{content} || '',
                doi => $tmp->{doi}->{content} || '',
                pmid => $tmp->{pmid}->{content} || '',
                citing_url => $tmp->{citingArticlesURL}->{content} || '',
                times_cited => $tmp->{timesCited}->{content} || '',
            };

            Catmandu->exporter->add($data);
        }
    } catch {
        print STDERR "Error: $_";
    }
}

sub run {
    my ($self) = @_;

    my $input = Catmandu->importer->to_array;

    while ( my @chunks = splice(@$input,0,20) ) {

        my $request_body = $self->_generate_xml(@chunks);

        try {
            my $response = $self->_do_request($request_body);
            $self->_parse_xml($response);
        } catch {
            print STDERR "Error: $_";
        }

    }
}

main->new_with_options->run;

1;
