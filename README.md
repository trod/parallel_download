# Parallel download

## Comments:
This is a simple web crawler which takes a list of urls and tries to concurrently download its content.
Concurrency is achieved by using [Tasks](https://hexdocs.pm/elixir/Task.html)


## Installation
  * Install dependencies with `mix deps.get`
  
## Tests
 Run tests with `make test`
 Run tests incl. coverage with `make coverage`

## Usage
 `make run ARGS="http://google.com http://bing.com"`
