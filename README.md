# external chaincode buildpack

This produces a small `luthersystems/buildpack` docker image artifact which is
intended to be used as an init container for a fabric peer pod running on
Kubernetes.  The init container and peer container should share an `emptyDir`
volume.  A directory on that volume should be supplied as the single argument to
the init container and as the location of the external buildpack in the peer
`core.yaml` config.  The init container will copy the buildpack scripts into
that directory on boot.
