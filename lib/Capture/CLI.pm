package Capture::CLI;

use strict;
use warnings;

use File::Spec;
use File::Temp qw(tempfile);

sub new { bless {}, shift }

sub main {
    my ( %args ) = @_;
    my $argv = $args{argv} || [];

    if ( !@$argv ) {
        print STDERR "Usage: dashboard capture.run <command-block>\n";
        return 1;
    }

    my $command_block = @$argv == 1 ? $argv->[0] : join q{ }, @$argv;
    my $output_path   = $ENV{OUTPUT} || File::Spec->catfile( File::Spec->tmpdir(), "capture-$$.txt" );

    __PACKAGE__->new->run(
        command_block => $command_block,
        output_path   => $output_path,
    );

    return 0;
}

sub run {
    my ( $self, %args ) = @_;

    my $command_block = $args{command_block};
    my $output_path   = $args{output_path} || File::Spec->catfile( File::Spec->tmpdir(), "capture-$$.txt" );

    my @commands = split /\n\n/, $command_block;
    unshift @commands, 'pwd';

    my ( $run_fh, $run_path ) = tempfile( 'capture-run-XXXXXX', DIR => File::Spec->tmpdir(), SUFFIX => '.sh' );

    for my $command (@commands) {
        my $width = length($command) + 7;
        print {$run_fh} qq{echo "} . ( '-' x $width ) . qq{"\n};
        print {$run_fh} "printf '%s\\n' " . _sh_single_quote("| >> $command |") . "\n";
        print {$run_fh} qq{echo "} . ( '-' x $width ) . qq{"\n};
        print {$run_fh} "$command\n";
    }
    close $run_fh or die "Unable to close $run_path: $!";

    my $transcript = q{};
    open my $exec, '-|', 'bash', $run_path or die "Unable to execute $run_path: $!";
    while ( my $line = <$exec> ) {
        print $line;
        $transcript .= $line;
    }
    close $exec;
    my $exit_code = $? >> 8;

    unlink $run_path or die "Unable to remove $run_path: $!";

    open my $cap, '>', $output_path or die "Unable to write $output_path: $!";
    print {$cap} $transcript;
    close $cap or die "Unable to close $output_path: $!";

    return {
        output_path => $output_path,
        transcript  => $transcript,
        exit_code   => $exit_code,
    };
}

sub _sh_single_quote {
    my ($text) = @_;
    $text =~ s/'/'"'"'/g;
    return "'$text'";
}

1;
