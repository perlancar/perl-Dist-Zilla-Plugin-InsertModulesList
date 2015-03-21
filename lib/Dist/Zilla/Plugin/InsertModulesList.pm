package Dist::Zilla::Plugin::InsertModulesList;

# DATE
# VERSION

use 5.010001;
use strict;
use warnings;

use Moose;
with (
    'Dist::Zilla::Role::FileMunger',
    'Dist::Zilla::Role::FileFinderUser' => {
        default_finders => [':InstallModules', ':ExecFiles'],
    },
);

use namespace::autoclean;

sub munge_files {
    my $self = shift;

    $self->munge_file($_) for @{ $self->found_files };
}

sub munge_file {
    my ($self, $file) = @_;
    my $content = $file->content;
    if ($content =~ s{^#\s*INSERT_MODULES_LIST\s*$}{$self->_insert_modules_list($1, $2)."\n"}egm) {
        $self->log(["inserting modules list into '%s'", $1, $2, $file->name]);
        $file->content($content);
    }
}

sub _insert_modules_list {
    my($self, $file, $name) = @_;

    # XXX use DZR:FileFinderUser's multiple finder feature instead of excluding
    # it manually again using regex

    my @list;
    for my $file (@{ $self->found_files }) {
        my $name = $file->name;
        next unless $name =~ s!^lib[/\\]!!;
        $name =~ s![/\\]!::!g;
        $name =~ s/\.(pm|pod)$//;
        push @list,
    }
    @list = sort @list;

    join(
        "",
        "=over\n\n",
        (map {"=item * L<>\n\n"} @list),
        "=back\n\n",
    );
}

__PACKAGE__->meta->make_immutable;
1;
# ABSTRACT: Insert a POD containing a list of modules in the distribution

=for Pod::Coverage .+

=head1 SYNOPSIS

In dist.ini:

 [InsertModulesList]

In lib/Foo.pm:

 ...

 =head1 DESCRIPTION

 This distribution contains the following modules:

 #INSERT_MODULES_LIST

 ...

After build, lib/Foo.pm will contain:

 ...

 =head1 DESCRIPTION

 This distribution contains the following modules:

 #INSERT_MODULES_LIST

 ...


=head1 DESCRIPTION

This plugin finds C<< # INSERT_MODULES_LIST >> directive in your POD/code and
replace it with a POD containing list of modules in the distribution.


=head1 SEE ALSO

L<Dist::Zilla::Plugin::InsertExecsList>
