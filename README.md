# Simple database benchmarks

The manifests in this repository deploy two MariaDB servers, one using host-local storage via an [emptyDir](https://kubernetes.io/docs/concepts/storage/volumes/#emptydir) volume and the other using a PVC from the default storage class (which on our clusters will be a Ceph pool of some sort). For each server we start up a benchmark job that uses [`mysqlslap`](https://dev.mysql.com/doc/refman/8.0/en/mysqlslap.html) to perform two sets of benchmarks:

1. The first uses data synthesized by `mysqlslap`
2. The second uses the `employees` dataset available from [the MySQL website](https://dev.mysql.com/doc/index-other.html) and runs a set of `SELECT` queries.

## Deploying the manifests

```
kubectl apply -k overlays/mariadb-local
kubectl apply -k overlays/mariadb-pv
```

## Viewing the results

Use `kuebctl logs` to view the logs of the benchmarking pods. In an ideal world, you can run:

```
kubectl logs jobs/benchmark-local
kubectl logs jobs/benchmark-pv
```
