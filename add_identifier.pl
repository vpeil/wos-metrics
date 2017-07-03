#!/usr/bin/env perl

use Catmandu::Sane;
use Catmandu;
use Moo;
use MooX::Options;
use Try::Tiny;

option verbose => (is => 'ro',
    short => 'v',
    doc => "Print details.",
    );
option file => (
    is => 'ro',
    format => 's',
    default => sub {'data/wos_citations.csv'},
    doc => "Specify the input file, default is 'ut.csv' in the pwd.",
    );
option dry => (
    is => 'ro',
    doc => 'Dry run option.'
);

Catmandu->load;

my $exporter = Catmandu->exporter('ids');

sub _compare {
    my ($self) = @_;

    my $bag = Catmandu->store->bag('wos');
    my $importer = Catmandu->importer->each(sub {
        my $orig = $_[0];
        my $new = $bag->get($orig->{_id});
        my $data = {_id => $orig->{_id}};
        foreach my $f (qw(ut doi pmid)) {
            if (!$orig->{$f} && $new->{$f} && $new->{$f} ne '') {
                $data->{$f} = $new->{$f};
            
            }
            $exporter->add($data) if keys %$data > 1;
	}
    });
}

sub run {
    my ($self) = @_;

    $self->_compare();
}

main->new_with_options->run;

1;
