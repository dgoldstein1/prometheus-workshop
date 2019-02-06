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
### PromQL

## Hands On Learning

### Exercises
### Challenge
### Additional Resources


## Authors

* **David Goldstein** - [davidcharlesgoldstein.com](http://www.davidcharlesgoldstein.com/?prometheus-workshop)

## License

This project is licensed under the MIT License - see the [LICENSE.md](LICENSE.md) file for details

