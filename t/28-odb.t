#!perl

use Test::More;
use File::Slurp::Tiny qw(write_file);
use File::Spec::Functions qw(catfile rel2abs);
use File::Path qw(make_path);
use Git::Raw;

my $path = rel2abs(catfile('t', 'test_repo'));
my $repo = Git::Raw::Repository -> open($path);

my $odb = $repo -> odb;
isa_ok $odb, "Git::Raw::Odb";
is $odb -> backend_count, 2;

$odb = Git::Raw::Odb -> open(catfile($repo -> path, 'objects'));
isa_ok $odb, "Git::Raw::Odb";
is $odb -> backend_count, 2;

$odb = Git::Raw::Odb -> new;
isa_ok $odb, "Git::Raw::Odb";
is $odb -> backend_count, 0;

my $pack = Git::Raw::Odb::Backend::Pack -> new(catfile($repo -> path, 'objects'));
isa_ok $pack, 'Git::Raw::Odb::Backend';

my $loose = Git::Raw::Odb::Backend::Loose -> new(catfile($repo -> path, 'objects'), 0);
isa_ok $loose, 'Git::Raw::Odb::Backend';

$odb -> add_backend($pack, 100);
is $odb -> backend_count, 1;
$odb -> refresh;

$odb -> add_backend($loose, 99);
is $odb -> backend_count, 2;
$odb -> refresh;

$repo -> odb($odb);

my $odb_path = rel2abs(catfile('t', 'odb'));
my $pack_index = catfile($odb_path, 'pack-8c875ec76737c36e18eb0eeccfb2d33d511d0efb.idx');
my $one_pack = Git::Raw::Odb::Backend::OnePack -> new($pack_index);
isa_ok $one_pack, 'Git::Raw::Odb::Backend';

done_testing;

