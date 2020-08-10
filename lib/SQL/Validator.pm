package SQL::Validator;

use 5.014;

use strict;
use warnings;

use registry;
use routines;

use Data::Object::Class;
use Data::Object::ClassHas;
use JSON::Validator;

# VERSION

our $GITHUB_SOURCE = 'iamalnewkirk/json-sql';

# ATTRIBUTES

has schema => (
  is  => 'ro',
  isa => 'Any',
  new => 1
);

fun new_schema($self) {
  my $version = $self->version;
  my $specification = "schemas/$version/rulesets.yaml";
  $ENV{SQL_VALIDATOR_SCHEMA}
    || "https://raw.githubusercontent.com/$GITHUB_SOURCE/master/$specification"
}

has validator => (
  is  => 'ro',
  isa => 'InstanceOf["JSON::Validator"]',
  new => 1
);

fun new_validator($self) {
  local $ENV{JSON_VALIDATOR_CACHE_ANYWAYS} = 1
    unless exists $ENV{JSON_VALIDATOR_CACHE_ANYWAYS};
  JSON::Validator->new
}

has version => (
  is  => 'ro',
  isa => 'Str',
  def => '0.0'
);

# METHODS

method error() {

  return $self->{error};
}

method validate(HashRef $schema) {
  my $validator = $self->validator;

  $validator->coerce('booleans');
  $validator->schema($self->schema);

  my @issues = $validator->validate($schema);

  if (@issues) {
    require SQL::Validator::Error;

    $self->{error} = SQL::Validator::Error->new(
      context => $self,
      issues => [@issues]
    );
  }
  else {
    delete $self->{error};
  }

  return !@issues ? 1 : 0;
}

1;