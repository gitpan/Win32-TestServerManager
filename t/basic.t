use strict;
use warnings;
use Test::More tests => 11;
use Win32::TestServerManager;

# spawn ready-made perl script

my $manager = Win32::TestServerManager->new;

ok !defined $manager->instance('test'), 'there should no test instance';
ok !defined $manager->process('test'), 'and there should no test process';
ok scalar $manager->instances == 0, 'they should not be autovivified';
eval {
  $manager->spawn( test => 't/script/sleep.pl' );
};
ok !$@, 'test server is launched successfully';

ok $manager->pid('test') > 0, 'and the pid is positive';

$manager->kill('test');

ok scalar $manager->instances == 0, 'and there is no instances';

# on the fly perl script

eval {
  $manager->spawn( test_on_the_fly => '',
    { create_server_with => sleep_server() }
  );
};
ok !$@, 'test server on the fly is launched successfully';

ok $manager->pid('test_on_the_fly') > 0, 'and the pid is positive';

my $on_the_fly = $manager->instance('test_on_the_fly');

ok -f $on_the_fly->{tmpfile}, 'temporary file exists';

$manager->kill('test_on_the_fly');

ok !-f $on_the_fly->{tmpfile}, 'temporary file is deleted';

ok scalar $manager->instances == 0, 'and there is no instances';

sub sleep_server { return <<'SERVER';
#!perl
use strict;
sleep 100;
SERVER
}