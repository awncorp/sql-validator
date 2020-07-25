package SQL::Validator::Error;

use 5.014;

use strict;
use warnings;

use registry;
use routines;

use Data::Object::Class;
use Data::Object::ClassHas;

extends 'Data::Object::Exception';

# VERSION

# ATTRIBUTES

has 'issues' => (
  is => 'ro',
  isa => 'ArrayRef[InstanceOf["JSON::Validator::Error"]]',
  req => 1,
);

# METHODS

method match(Str $key = '/') {
  $key =~ s/^\/*/\//;

  my @matches = grep {$_->path =~ /^$key/} @{$self->issues};

  return [@matches];
}

method report(Str $key = '/') {
  my $matches = $self->match($key);

  return join "\n", sort map "$_", @$matches;
}

1;