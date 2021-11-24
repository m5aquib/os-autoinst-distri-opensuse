# SUSE's openQA tests
#
# Copyright 2021 SUSE LLC
# SPDX-License-Identifier: FSFAP

# Summary: Helper class for amazon connection and authentication
#
# Maintainer: qa-c team <qa-c@suse.de>

package publiccloud::k8s_provider;
use Mojo::Base -base;
use testapi;
use mmapi 'get_current_job_id';

has region => undef;
has resource_name => sub { get_var('PUBLIC_CLOUD_RESOURCE_NAME', 'openqa-vm') };
has provider_client => undef;

sub init {
    my ($self, $service) = @_;
    die('The service must be specified') if (!$service);

    my $provider = get_required_var('PUBLIC_CLOUD_PROVIDER');

    if ($provider eq 'EC2') {
        $self->provider_client(
            publiccloud::aws_client->new(
                region => $self->region,
                service => $service
            ));
    }
    elsif ($provider eq 'GCE') {
        die('Not implemented yet');
    }
    elsif ($provider eq 'AZURE') {
        die('Not implemented yet');
    }
    else {
        die("Invalid provider");
    }


    $self->provider_client->init();
}

=head2 get_container_registry_prefix
Get the full registry prefix URL (based on the account and region) to push container images on ECR.
=cut
sub get_container_registry_prefix {
    my ($self) = @_;
    return $self->provider_client->get_container_registry_prefix();
}

=head2 get_container_image_full_name
Returns the full name of the container image in ECR registry
C<tag> Tag of the container
=cut
sub get_container_image_full_name {
    my ($self, $tag) = @_;
    return $self->provider_client->get_container_image_full_name($tag);
}

=head2 get_default_tag
Returns a default tag for container images based of the current job id
=cut
sub get_default_tag {
    my ($self) = @_;
    return join('-', $self->resource_name, get_current_job_id());
}

1;
