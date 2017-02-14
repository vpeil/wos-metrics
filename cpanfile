requires 'perl', 'v5.10.1';

on 'test' => {
  requires 'Test::More';
  requires 'Test::Script', '>=1.10';
};

requires 'Catmandu';
requires 'Moo';
requires 'MooX::Options';
requires 'XML::Writer';
requires 'XML::Simple';
requires 'Try::Tiny';
requires 'LWP::UserAgent';
