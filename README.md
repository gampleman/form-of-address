# Form of Address

> a name or title used in speaking or writing to a person of a specified rank or function.

This is a simple address book app. The front-end is written in Elm and the backend
uses Praxis.

## Installation

You will need the following prerequisites:

- Ruby 2.3
- Postgress
- Bundler
- Elm
- Node
- node-elm-test

Then run:

    bundle install
    elm package install --yes

This should install all the other dependencies.

## Running the tests

Run the back-end tests with

    bundle exec rspec

Run the front-end tests with

    elm test

## Running the app

Run the app with

    bundle exec rackup -p 8888

The app will load on http://localhost:8888

## Building the client side code

    elm make ui/Main.elm

## Running the docs for the public API provided by the server

    bundle exec rake praxis:docs:preview

This will open a web broswer for you.

## License

(c) 2016 Jakub Hampl

MIT
