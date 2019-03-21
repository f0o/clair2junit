# clair2junit
A naive approach in converting clair reports into junit xml to be parsed in other tools

Right now it's really naive, it doesnt parse much but the Advisory, Package and Version affected.

Maybe in future I add the description, if it makes sense.

## Requirements

* bash
* jq
* tr
* cut

## Usage

As simple as: `cat clair-report.json | clair2junit > report.xml`
