#!/bin/bash

make_requests() {
    randomNumerEndpoint="localhost:7000"
    randomWikipediaEndpoint="localhost:7001"
    while true; do
        curl -s "$randomNumerEndpoint/randomNumber?max=10000000000" > /dev/null
        curl -s "$randomWikipediaEndpoint/randomArticle" > /dev/null
        # sleep 1
    done
}

echo "making requests to services.. press ^C to exit"
make_requests