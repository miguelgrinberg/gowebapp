#!/bin/bash -e

# This script deletes all the resources associated with a MicroFlack kubernetes
# deployment.

KUBECTL=$(which kubectl || true)
if [[ "$KUBECTL" == "" ]]; then
    echo Please install and configure kubectl for your cluster.
    exit 1
fi

$KUBECTL delete --ignore-not-found=true service gowebapp mysql
$KUBECTL delete --ignore-not-found=true deployment gowebapp mysql
$KUBECTL delete --ignore-not-found=true pvc mysql-pv-claim
$KUBECTL delete --ignore-not-found=true pv mysql-pv
$KUBECTL delete --ignore-not-found=true secret mysql

echo gowebapp has been removed.

