# Working through the Pachyderm tutorial, using gcloud, and haskell exe

http://pachyderm.readthedocs.io/en/latest/getting_started/beginner_tutorial.html
http://pachyderm.io/

## Step 0, install nixpkgs

See https://nixos.org/nix/

Note: it can be installed in conjunction with your normal O/S.  No need
for the multi-user install.

I (@alanz) install it so that the nix stuff is put on my path when I
run zsh (rather than my normal bash). This allows me to cleanly
partition when I use my normal setup and when I use nix.

The complex set of *.nix files are to make sure that we are using an
absolutely repeatable configuration, and is based on
https://nixos.wiki/wiki/How_to_fetch_Nixpkgs_with_an_empty_NIX_PATH

## Establish local environment

```
% nix-shell --pure
```

This starts up a bash shell, with the required dependencies (only) on
the path.

As per http://pachyderm.readthedocs.io/en/latest/deployment/google_cloud_platform.html, it installs

- google cloud sdk
- kubectl
- pachctl

## Set up gcloud

See https://cloud.google.com/sdk/docs/quickstart-debian-ubuntu#initialize_the_sdk

Run

```
$ gcloud init
```

And set up against a Google Compute Engine account


## Start up kubernetes cluster

https://cloud.google.com/compute/docs/regions-zones/

```
$ gcloud compute regions list
NAME                     CPUS  DISKS_GB  ADDRESSES  RESERVED_ADDRESSES  STATUS  TURNDOWN_DATE
...
europe-west1             0/24  0/4096    0/8        0/8                 UP
europe-west2             0/24  0/4096    0/8        0/8                 UP
europe-west3             0/24  0/4096    0/8        0/8                 UP
europe-west4             0/24  0/4096    0/8        0/8                 UP
...
```

`europe-west1` is in Belgium, and has SSDs
`europe-west2` is in London, and has SSDs

It seems that `europe-west1` is the biggest/most feature complete.

Set up variables

```
CLUSTER_NAME="pachyderm-play"
GCP_ZONE="europe-west2-a"
gcloud config set compute/zone ${GCP_ZONE}
gcloud config set container/cluster ${CLUSTER_NAME}
MACHINE_TYPE="n1-standard-4"
gcloud config set container/new_scopes_behavior true
# By default the following command spins up a 3-node cluster. You can change the default with `--num-nodes VAL`.
gcloud container clusters create ${CLUSTER_NAME} --scopes storage-rw --machine-type ${MACHINE_TYPE}
```

Once it finishes the startup it should say something like

```
Created [https://container.googleapis.com/v1/projects/pachyderm-play/zones/europe-west2-a/clusters/pachyderm-play].
To inspect the contents of your cluster, go to: https://console.cloud.google.com/kubernetes/workload_/gcloud/europe-west2-a/pachyderm-play?project=pachyderm-play
kubeconfig entry generated for pachyderm-play.
NAME            LOCATION        MASTER_VERSION  MASTER_IP       MACHINE_TYPE   NODE_VERSION  NUM_NODES  STATUS
pachyderm-play  europe-west2-a  1.8.8-gke.0     35.197.206.203  n1-standard-4  1.8.8-gke.0   3          RUNNING
```

Get status

```
kubectl get pods -n kube-system
NAME                                                       READY     STATUS    RESTARTS   AGE
event-exporter-v0.1.7-5c4d9556cf-6pgxh                     2/2       Running   0          3m
fluentd-gcp-v2.0.9-dlx56                                   2/2       Running   0          3m
fluentd-gcp-v2.0.9-jt642                                   2/2       Running   0          3m
fluentd-gcp-v2.0.9-zq2hj                                   2/2       Running   0          3m
heapster-v1.4.3-dbd885dbd-gs44g                            3/3       Running   0          2m
kube-dns-778977457c-9fxlz                                  3/3       Running   0          3m
kube-dns-778977457c-b2z4x                                  3/3       Running   0          3m
kube-dns-autoscaler-7db47cb9b7-l44ws                       1/1       Running   0          3m
kube-proxy-gke-pachyderm-play-default-pool-7d168900-9b23   1/1       Running   0          3m
kube-proxy-gke-pachyderm-play-default-pool-7d168900-fl1g   1/1       Running   0          3m
kube-proxy-gke-pachyderm-play-default-pool-7d168900-vwkp   1/1       Running   0          3m
kubernetes-dashboard-768854d6dc-vwfbp                      1/1       Running   1          3m
l7-default-backend-6497bcdb4d-msz87                        1/1       Running   0          3m
```

## Deploy pachyderm

### Set up the storage resources

```
# 10Gb disk to play
STORAGE_SIZE="10"
# The bucket name must be globally unique
BUCKET_NAME="haskell-pachyderm-play"
gsutil mb gs://${BUCKET_NAME}
```

Check that it is created ok

```
$ gsutil ls
gs://haskell-pachyderm-play/
```

### Install pachctl (already done via nix-shell)

```
pachctl version --client-only
1.7.1
```

### Deploy pachyderm on the k8s cluster

The following command will report an error, because of the RBAC
problem.  But we will then fix it after.
See https://github.com/pachyderm/pachyderm/issues/2787#issuecomment-379622110

```
$ pachctl deploy google ${BUCKET_NAME} ${STORAGE_SIZE} --dynamic-etcd-nodes=1
```

Fix the RBAC permissions
```
kubectl delete clusterrolebinding pachyderm
kubectl create clusterrolebinding pachyderm --clusterrole=cluster-admin --serviceaccount=pachyderm:pachyderm --namespace=pachyderm --user=system:serviceaccount:default:pachyderm
kubectl delete pods --all
```

Check status (wait, takes some time, will first terminate the "bad" ones, then load new ones)
```
% kubectl get pods
NAME                     READY     STATUS    RESTARTS   AGE
dash-208784644-jk51f     2/2       Running   0          50s
etcd-0                   1/1       Running   0          52s
pachd-1573300529-xzl13   1/1       Running   0          51s
```

### Set up port fowarding

```
pachctl port-forward &
```

Check

```
% pachctl version
COMPONENT           VERSION
pachctl             1.7.1
pachd               1.7.1
```


## Testing the haskell docker container
This is based on
http://pachyderm.readthedocs.io/en/latest/getting_started/beginner_tutorial.html

It will copy `/pfs/in/file` to `/pfs/out/file`

```
$ pachctl create-repo in

# See the repo we just created
$ pachctl list-repo
NAME                CREATED             SIZE
in                  10 seconds ago      0B
```

Put some data into the repo, onto the master branch

```
$ pachctl put-file in master file -c -f http://imgur.com/46Q8nDz.png
```

Check

```
$ pachctl list-repo
NAME                CREATED             SIZE
in                  2 minutes ago       57.27KiB
```

We can view the commit we just created
```
$ pachctl list-commit in
```

View the image

```
$ pachctl get-file in master file | display
```

## Create the pipeline

We build a docker image according to ./test-transform/README.md.

The gist of it is the `SimpleMain.hs` exe
```haskell
module Main where

import System.Directory(copyFile)

main :: IO ()
main = do
  copyFile "/pfs/in/file" "/pfs/out/file"
```

which is packed into a dockerfile and pushed to dockerhub.

This has the location of the stripped haskell binary inserted into the
PATH of the docker user (root) that will be run by pachyderm.

The cabal file calls the exe simple, so the pipeline is configured as

(haskell-test.json)
```json
{
  "pipeline": {
    "name": "haskell-test"
  },
  "transform": {
      "image": "alanz/simple-container",
      "cmd":["simple"]
  },
  "input": {
    "atom": {
      "repo": "in",
      "glob": "/*"
    }
  }
}
```

```
$ pachctl create-pipeline -f haskell-test.json
```

Check status.

```
kubectl get pods
kubectl describe pod/pipeline-haskell-test-XXXXX

pachctl list-pipeline
pachctl inspect-pipeline haskell-test
pachctl list-job
```


Note, will see nothing initially, pachyderm first has to pull the
docker image. So waiting a few minutes for first run is not unusual

```
$ pachctl list-job
ID                               OUTPUT COMMIT                                 STARTED        DURATION   RESTART PROGRESS  DL       UL       STATE
594d40edfc3d48a2a7390674d02bd278 haskell-test/d99e910b1335441e8216265f3cb3a018 33 seconds ago 31 seconds 0       1 + 0 / 1 57.27KiB 57.27KiB success
```

See the result

```
$ pachctl list-repo
NAME                CREATED              SIZE
haskell-test        About a minute ago   57.27KiB
in                  9 minutes ago        57.27KiB
```

See the output

```
pachctl get-file haskell-test master file | display
```
