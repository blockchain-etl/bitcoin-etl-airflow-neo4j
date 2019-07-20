#!/bin/bash

pipenv lock --requirements | tail -n +2 | sed -e 's/;.*$//g' > requirements.txt
