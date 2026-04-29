use strict;
use warnings;

use Cwd ();
use File::Path qw(make_path);
use File::Spec;
use File::Temp qw(tempdir);
use FindBin qw($Bin);
use Test::More;

use lib File::Spec->catdir( $Bin, '..', 'lib' );

use Capture::CLI ();

sub slurp {
    my ($path) = @_;
    open my $fh, '<', $path or die "Unable to read $path: $!";
    local $/;
    return <$fh>;
}

{
    my $tmp = tempdir( CLEANUP => 1 );
    my $work = File::Spec->catdir( $tmp, 'work' );
    make_path($work);

    my $output = File::Spec->catfile( $tmp, 'transcript.txt' );
    local $ENV{OUTPUT} = $output;

    my $old = Cwd::getcwd();
    chdir $work or die "Unable to chdir to $work: $!";

    my $stdout = '';
    open my $out, '>', \$stdout or die "Unable to open stdout scalar: $!";
    local *STDOUT = $out;

    my $exit = Capture::CLI::main( argv => [ "printf 'hello\\n'\n\nprintf 'world\\n'" ] );
    is( $exit, 0, 'main returns success for a command block' );

    chdir $old or die "Unable to restore cwd to $old: $!";

    my $saved = slurp($output);
    is( $saved, $stdout, 'saved transcript matches stdout transcript' );
    like( $stdout, qr/\|\s>>\spwd\s\|/, 'transcript includes prepended pwd banner' );
    like( $stdout, qr/\|\s>>\sprintf 'hello\\n'\s\|/, 'transcript includes first command banner' );
    like( $stdout, qr/\|\s>>\sprintf 'world\\n'\s\|/, 'transcript includes second command banner' );
    like( $stdout, qr/\Q$work\E/, 'transcript records working directory output' );
    like( $stdout, qr/^hello$/m, 'transcript captures first command output' );
    like( $stdout, qr/^world$/m, 'transcript captures second command output' );
}

{
    my $stderr = '';
    open my $err, '>', \$stderr or die "Unable to open stderr scalar: $!";
    local *STDERR = $err;

    my $exit = Capture::CLI::main( argv => [] );
    is( $exit, 1, 'main returns usage error when no command is provided' );
    like( $stderr, qr/^Usage: dashboard capture\.run <command-block>/, 'usage error explains the required argument' );
}

{
    my $tmp = tempdir( CLEANUP => 1 );
    my $output = File::Spec->catfile( $tmp, 'custom.txt' );
    my @before = glob File::Spec->catfile( File::Spec->tmpdir(), 'capture-run-*.sh' );

    my $json = Capture::CLI->new->run(
        command_block => "printf 'before\\n'\n\nfalse\n\nprintf 'after\\n'",
        output_path   => $output,
    );

    is( $json->{output_path}, $output, 'run reports the output path' );
    ok( -f $output, 'run writes the transcript file' );
    is( $json->{exit_code}, 0, 'run returns the shell close status of the last command in the block' );
    my $saved = slurp($output);
    like( $saved, qr/^before$/m, 'run output file contains output before a failure' );
    like( $saved, qr/^after$/m, 'run output file contains output after a failure' );

    my @after = glob File::Spec->catfile( File::Spec->tmpdir(), 'capture-run-*.sh' );
    is_deeply( \@after, \@before, 'temporary helper script is cleaned up after the run' );
}

{
    local $ENV{OUTPUT};

    my $stdout = '';
    open my $out, '>', \$stdout or die "Unable to open stdout scalar: $!";
    local *STDOUT = $out;

    my $exit = Capture::CLI::main( argv => [ q{printf 'auto-path-ok\n'} ] );
    is( $exit, 0, 'main succeeds without explicit OUTPUT' );

    like( $stdout, qr/^auto-path-ok$/m, 'default-output run still prints command output' );
    like( $stdout, qr/^Capture saved to: (\/tmp\/capture-\d+\.txt)$/m, 'default-output run prints the saved transcript path at the end' );
    my ($path) = $stdout =~ /^Capture saved to: (\/tmp\/capture-\d+\.txt)$/m;
    ok( defined $path && -f $path, 'reported default transcript path exists' );
    like( slurp($path), qr/^auto-path-ok$/m, 'default transcript file contains the command output' );
    unlink $path or die "Unable to remove $path: $!";
}

done_testing;
