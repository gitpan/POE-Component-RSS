#!/usr/bin/perl -w

use strict;

$| = 1;

print "1..1\n";

eval "
  use POE;
  use POE::Component::RSS;
";

if ($@) {
  print "not ok 1\n";
} else {
  print "ok 1\n";
}
