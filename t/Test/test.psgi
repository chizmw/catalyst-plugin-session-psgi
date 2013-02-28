use strict;
use warnings;

use Test;

my $app = Test->apply_default_middlewares(Test->psgi_app);
$app;

