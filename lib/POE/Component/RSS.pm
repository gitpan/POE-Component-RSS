package POE::Component::RSS;

use strict;

use XML::RSS;
use POE;
use Carp qw(croak);
use vars qw(@ISA %EXPORT_TAGS @EXPORT_OK @EXPORT $VERSION);

require Exporter;

@ISA = qw(Exporter);

# Items to export into callers namespace by default. Note: do not export
# names by default without a very good reason. Use EXPORT_OK instead.
# Do not simply export all your public functions/methods/constants.

# This allows declaration	use POE::Component::RSS ':all';
# If you do not need this, moving things directly into @EXPORT or @EXPORT_OK
# will save memory.
%EXPORT_TAGS = ( 'all' => [ qw(
	
) ] );

@EXPORT_OK = ( @{ $EXPORT_TAGS{'all'} } );

@EXPORT = qw(
	
);
$VERSION = '0.06';


# Preloaded methods go here.

# Spawn a new PoCo::RSS session
sub spawn {
  my $type = shift;
  croak "$type requires an even number of parameters" if @_ % 2;

  my %params = @_;

  my $alias = delete $params{'Alias'};

  $alias = 'rss' unless defined($alias) and length($alias);

  croak("$type doesn't know these parameters: ",
	join (', ', sort keys %params))
    if scalar keys %params;

  POE::Session->create(
		       inline_states => {
					 _start => \&rss_start,
					 _stop => \&rss_stop,
					 parse => \&got_parse,
					},
		       args => [$alias ],
		      );
  undef;

}

sub got_parse {

  my ($kernel, $heap, $sender, $return_states, $rss_string, $rss_identity_tag) =
    @_[KERNEL, HEAP, SENDER, ARG0, ARG1, ARG2];

  my @rss_tag;

  if (defined($rss_identity_tag)) {
      @rss_tag = ($rss_identity_tag);
  } else {
      @rss_tag = ();
  }

  my $rss_parser = new XML::RSS;
  
  $rss_parser->parse($rss_string);
  
  if (exists $return_states->{'Start'}) {
      $kernel->post($sender, $return_states->{'Start'}, @rss_tag);
  }

  if (exists $return_states->{'Item'}) {
      foreach my $item (@{$rss_parser->{'items'}}) {
	  # $item->{'title'}
	  # $item->{'link'}
	  $kernel->post($sender, $return_states->{'Item'}, @rss_tag, $item);
      }
  }

  if (exists $return_states->{'Channel'}) {
      $kernel->post($sender, $return_states->{'Channel'}, @rss_tag, $rss_parser->{'channel'});
  }

  if (exists $return_states->{'Image'}) {
      $kernel->post($sender, $return_states->{'Image'}, @rss_tag, $rss_parser->{'image'});
  }

  if (exists $return_states->{'Textinput'}) {
      $kernel->post($sender, $return_states->{'Textinput'}, @rss_tag, $rss_parser->{'textinput'});
  }
  
  if (exists $return_states->{'Stop'}) {
      $kernel->post($sender, $return_states->{'Stop'}, @rss_tag);
  }

  return;

}

sub rss_start {
  my ($kernel, $heap, $alias) = @_[KERNEL, HEAP, ARG0];
  
  $kernel->alias_set($alias);

}

sub rss_stop {
  my ($kernel, $heap) = @_[KERNEL, HEAP];

}

# Autoload methods go after =cut, and are processed by the autosplit program.

1;
__END__

=head1 NAME

POE::Component::RSS - Event based RSS parsing

=head1 SYNOPSIS

  use POE qw(Component::RSS);

  POE::Component::RSS->spawn();

  $kernel->post('rss', 'parse', {
                         Item => 'item_state',
                       },
                     , $rss_string);

=head1 DESCRIPTION

POE::Component::RSS is an event based RSS parsing module. It wraps
XML::RSS and provides a POE based framework for accessing the information
provided.

RSS parser components are not normal objects, but are instead 'spawned'
as separate sessions. This is done with PoCo::RSS's 'spawn' method, which
takes one named parameter:

=over 4

=item C<Alias => $alias_name>

'Alias' sets the name by which the session is known. If no alias
is given, the component defaults to 'rss'. It's possible to spawn
several RSS components with different names.

=back

Sessions communicate asynchronously with PoCo::RSS - they post requests
to it, and it posts results back.

Parse requests are posted to the component's 'parse' state, and
include a hash of states to return results to, and a RSS string to
parse, followed by an optional identity parameter. For example:

  $kernel->post('rss', 'parse',
                       { # hash of result states
                         Item => 'item_state',
                         Channel => 'channel_state',
                         Image => 'image_state',
                         Textinput => 'textinput_state',
                         Start => 'start_state',
                         Stop => 'stop_state',
                       },
                     , $rss_string, $rss_identity_tag);

Currently supported result events are:

=over 4

=item C<Item => 'item_state'>

A state to call every time an item is found within the RSS
file. Called with a reference to a hash which contains all attributes
of that item.

=item C<Channel => 'channel_state'>

A state to call every time a channel definition is found within the
RSS file. Called with a reference to a hash which contains all attributes
of that channel.

=item C<Image => 'image_state'>

A state to call every time an image definition is found within the
RSS file. Called with a reference to a hash which contains all attributes
of that image.

=item C<Textinput => 'textinput_state'>

A state to call every time a textinput definition is found within the
RSS file. Called with a reference to a hash which contains all attributes
of that textinput.

=item C<Start => 'start_state'>

A state to call at the start of parsing.

=item C<Stop => 'stop_state'>

A state to call at the end of parsing.

=back

If an identity parameter was supplied with the parse event, the first
parameter of all result events is that identity string. This allows easy
identification of which parse a result is for.

=head1 TODO

=over 4

=item *

Provide event based generation of RSS files.

=item *

Provide more of the information in an RSS file as events.

=item *

We depend on the internals of XML::RSS. This is bad and should be
fixed.

=back

=head1 BUGS

=over 4

=item *

Some events may be emitted even if no data was found. Calling
code should check return data to verify content.

=back

=head1 AUTHOR

Michael Stevens - michael@etla.org.

=head1 SEE ALSO

perl(1). This component is built upon XML::RSS(3).

=cut
