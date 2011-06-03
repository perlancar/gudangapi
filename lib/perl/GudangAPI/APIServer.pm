package GudangAPI::APIServer;

use 5.010;
use strict;
use warnings;
use Log::Any '$log';

use Moo;
extends 'Sub::Spec::HTTP::Server';

use GudangAPI::App::APISpecs;

sub before_prefork {
    $log->trace("-> GA's before_prefork()");
    my ($self) = @_;

    for my $m (keys %GudangAPI::App::api_specs) {
        $m =~ s!::!/!g;
        $log->trace("Loading API module $m ...");
        require "GudangAPI/API/$m.pm";
    }
}

sub get_sub_name {
    my ($self) = @_;
    my $req = $self->req;
    my $http_req = $req->{http_req};

    # intercept /, give help
    if ($http_req->uri =~ m!^/+$!) {
        $self->resp([
            404, "Please go to http://www.gudangapi.com/ for help."]);
        die;
    }
    $self->SUPER::get_sub_name;
}

1;
