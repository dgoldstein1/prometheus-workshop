# Prometheus Workshop

This repo is a hands-on tutorial to become familiar with Prometheus. It consisits of:

1. [Introduction](#Introduction)
	1. [Getting Started](#Getting-Started)
	2. [Getting Oriented](#Getting-Oriented)
	3. [PromQL](#PromQL)
2. [Hands On Learning](#Hands-On-Learning)
	1. [Exercises](#Exercises)
	2. [Challenge](#Challenge)
	3. [Additional Resources](#Additional-Resources)

## Introduction to Prometheus

Prometheus is a time series database which monitors service metrics easily and efficienctly. It works by scraping a set of services on an interval and then exposing those metrics through an API. In this section of the walkthough we will setup a local prometheus instance with a few example services and explore Prometheus's core features.

### Getting Started

Let's get our local environment up and running. In this example, Prometheus is inside its own docker image, so we won't need to install any binaries. Run the following to pull and start all the containers:

```sh
docker-compose up -d
```

After everything has started, make sure everything is running succesfully with:

```sh
docker-compose ps
```

### Getting Oriented

There are now three things running: prometheus and two services which I wrote for this tutorial. Let's first look at these two services.

Make the following request to the `random-wikipedia-article` service:

```sh
curl localhost:7001/randomArticle
"Golyam Perelik (Bulgarian: Голям Перелик) is the highest peak in the Rhodope Mountains, situated 19 km to the west of Smolyan. It makes the Rhodopes the seventh highest Bulgarian mountains..."
```

This service exposes two endpoints `/randomArticle` and `/metrics`. As you can see, `/randomArticle` fetches a random wikipedia article and outputs an extract in plain text. Now let's make a request to `/metrics`:

```sh
curl localhost:7001/metrics
# HELP go_gc_duration_seconds A summary of the GC invocation durations.
# TYPE go_gc_duration_seconds summary
go_gc_duration_seconds{quantile="0"} 8.0927e-05
go_gc_duration_seconds{quantile="0.25"} 0.000111602
go_gc_duration_seconds{quantile="0.5"} 0.000130777
go_gc_duration_seconds{quantile="0.75"} 0.000187794
go_gc_duration_seconds{quantile="1"} 0.000272113
go_gc_duration_seconds_sum 0.001172767
go_gc_duration_seconds_count 8
...
```

This is where prometheus comes into play. Using the [golang prometheus client library](https://github.com/prometheus/client_golang), the `/metrics` endpoint exposes a whole bunch of information about the random-wikipedia service in a format which prometheus can easily read.

Prometheus scrapes these endpoints on a given interval. In our case, I have set this to every 15 seconds. If you navigate to `http://localhost:9090/targets`, Prometheus will show you all the targets it's currently scraping, their statuses, and the time since it was last scrape. Note that prometheus can also monitor itself.

![promTargets](images/prom-targets.png)

Look through all the metrics for the service `random-wikipedia-article`. Are there any metrics you can understand right off the bat? A lot of these metrics are general enough to be human readable and include brief explanations after `#HELP`. 

Now Let's take a closer look at the metric `promhttp_metric_handler_requests_total`. This metric tells us the number of times the `/metrics` endpoint has been hit.

Run the command :

```sh
curl -s localhost:7001/metrics | grep _metric_handler_requests_total
# HELP promhttp_metric_handler_requests_total Total number of scrapes by HTTP status code.
# TYPE promhttp_metric_handler_requests_total counter
promhttp_metric_handler_requests_total{code="200"} 20
promhttp_metric_handler_requests_total{code="500"} 0
promhttp_metric_handler_requests_total{code="503"} 0
```

Here we can see that the `/metrics` endpoint has been hit 20 times, and all 20 of them were 200-level responses. 

Run the `curl` request a few more times. Note that `promhttp_metric_handler_requests_total{code="200"}` is incremented every time you run it. This is because we are making a request to the `/metrics` endpoint, which registers as a 200-level response for `/metrics` endpoint for the `random-wikipedia-article` service. 

If we were to run:

```sh
for i in `seq 1 100`;
do
	curl -s localhost:7001/metrics > /dev/null
done
curl -s localhost:7001/metrics | grep _metric_handler_requests_total
# HELP promhttp_metric_handler_requests_total Total number of scrapes by HTTP status code.
# TYPE promhttp_metric_handler_requests_total counter
promhttp_metric_handler_requests_total{code="200"} 121
promhttp_metric_handler_requests_total{code="500"} 0
promhttp_metric_handler_requests_total{code="503"} 0
```
We would note that the total number of "scrapes" registers as:

- the nuber I had before (20) +
- the number of scrapes I just did (100) +
- the number of scrapes done while that script was running (1)

= 121

This kind of metric is called a [counter](https://prometheus.io/docs/concepts/metric_types/#counter). It is only incrememented or decremented. This is different than something like `go_memstats_alloc_bytes` (amount of memory the service is using), which represents a specific unit which can change drastically between scrapes. This is called a [gauge](https://prometheus.io/docs/concepts/metric_types/#gauge). These two types of metrics are the most important for promethues, but for more information on different metrics, see the [prometheus documentation](https://prometheus.io/docs/concepts/metric_types).

### PromQL

Prometheus uses its own query language called PromQL. PromQL is specially designed to handle time series-like queries and ranging over large amounts of data.

Unfortunatley, PromQL has a high learning curve. If you find yourself getting frusterated, know that someone else is likely in the same situation-- don't be afraid to ask for clarification :)

Let's get started. Open up the Prometheus console by going to `localhost:9090`: 

![prom-console](images/prom-console.png)

This is the central place for experimenting with queries and debugging metrics.

Let's play aroud with the metric we were looking at before: `promhttp_metric_handler_requests_total`. Type "promhttp_metric_handler_requests_total" into the console bar and press "execute."

```
promhttp_metric_handler_requests_total{code="200",instance="localhost:9090",job="prometheus"}	9
...
```

We can see that we've just executed a query against our data in Prometheus. 

Note that if you open up the network tab in dev tools, you can see this request being made against `http://localhost:9090/api/v1/query?query=promhttp_metric_handler_requests_total`. Prometheus exposes `/api/{version}/query` to be used as an API endpoint. For more information see [prometheus api](https://prometheus.io/docs/prometheus/latest/querying/api/).

Let's take a closer look at our data:

```
promhttp_metric_handler_requests_total{code="200",instance="localhost:9090",job="prometheus"}	21
promhttp_metric_handler_requests_total{code="200",instance="random-number-generator:8080",job="random-number-generator"}	21
promhttp_metric_handler_requests_total{code="200",instance="random-wikipedia:8080",job="random-wikipedia"}	21
promhttp_metric_handler_requests_total{code="500",instance="localhost:9090",job="prometheus"}	0
promhttp_metric_handler_requests_total{code="500",instance="random-number-generator:8080",job="random-number-generator"}	0
promhttp_metric_handler_requests_total{code="500",instance="random-wikipedia:8080",job="random-wikipedia"}	0
promhttp_metric_handler_requests_total{code="503",instance="localhost:9090",job="prometheus"}	0
promhttp_metric_handler_requests_total{code="503",instance="random-number-generator:8080",job="random-number-generator"}	0
promhttp_metric_handler_requests_total{code="503",instance="random-wikipedia:8080",job="random-wikipedia"}	0
```

From this output, we can see that Prometheus has registered three different *labels* for out data: 
 - `code` - the response-code for the request to `/metrics`
 - `instance` - the http endpoint for that specific service
 - `job` - the name of the service

 Let's say all we care about right now is `random-wikipedia`. We can specify the name of the `job` to equal `random-wikipedia` by putting this label in our query. Enter in `promhttp_metric_handler_requests_total{job="random-wikipedia"}` into the console. Now all you should see are elements where the tag is equal to `random-wikipedia`:

 ```
 promhttp_metric_handler_requests_total{code="200",instance="random-wikipedia:8080",job="random-wikipedia"}	72
promhttp_metric_handler_requests_total{code="500",instance="random-wikipedia:8080",job="random-wikipedia"}	0
promhttp_metric_handler_requests_total{code="503",instance="random-wikipedia:8080",job="random-wikipedia"}	0
 ```

Now let's say we want to get the number of metric scrapes from 10 minutes ago for the `random-number-generator` service. We could use the modifier `offset {time}` in order to offset our data. Enter in `promhttp_metric_handler_requests_total{job="random-number-generator"} offset 10m`. You should see the values decrease for the 200-level responses, since we are looking at historical data:

```
promhttp_metric_handler_requests_total{code="200",instance="random-number-generator:8080",job="random-number-generator"}	77
promhttp_metric_handler_requests_total{code="500",instance="random-number-generator:8080",job="random-number-generator"}	0
promhttp_metric_handler_requests_total{code="503",instance="random-number-generator:8080",job="random-number-generator"}	0
```



## Hands On Learning

### Exercises
### Challenge
### Additional Resources


## Authors

* **David Goldstein** - [davidcharlesgoldstein.com](http://www.davidcharlesgoldstein.com/?prometheus-workshop)

## License

This project is licensed under the MIT License - see the [LICENSE.md](LICENSE.md) file for details

