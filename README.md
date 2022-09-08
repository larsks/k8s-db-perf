# Simple database benchmarks

This repository implements some simple database benchmarks to compare local storage vs. NESE-hosted storage in our OpenShift clusters. Deploying these manifests will create:

1. A MariaDB server backed by local storage (an [emptyDir][] volume)
1. A MariaDB server backed by a [PVC][] from the default storage class (which in the clusters of interest will be Ceph RBD storage from NESE)
1. A benchmark [job][] running [mysqlslap][] for each of the above database instances.
1. A web interface for viewing the benchmark results

[emptyDir]: https://kubernetes.io/docs/concepts/storage/volumes/#emptydir
[mysqlslap]: https://dev.mysql.com/doc/refman/8.0/en/mysqlslap.html
[job]: https://kubernetes.io/docs/concepts/workloads/controllers/job/
[pvc]: https://kubernetes.io/docs/concepts/storage/persistent-volumes/

## The benchmarks

The benchmarks are run by the [benchmark.sh][] script. We run two `mysqlslap` configurations:

1. The first uses data and queries synthesized by `mysqlslap`.
2. The second uses the `employees` database mentioned in [the MySQL documentation][docs] and a set of explicit queries

[benchmark.sh]: ./benchmarks/base/scripts/benchmark.sh

## Deploying the manifests

```
kubectl apply -k .
```

## Viewing the results

You can use `kubectl logs` to view the benchmark results:

```
kubectl logs jobs/benchmark-local
kubectl logs jobs/benchmark-pv
```

If you prefer browser-based access, these manifests will make a webserver available at the route defined by [./console/routes/console.yaml][]. The web page is dynamic so just load it and wait; eventually the results will show up.

[./console/routes/console.yaml]: ./console/routes/console.yaml
