#!/bin/bash
npm unpublish local-toolbox@0.0.0
grunt build
npm publish
