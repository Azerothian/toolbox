#!/bin/bash
npm unpublish local-toolbox@0.0.0
grunt build

cp package.json build/
cp README.md build/
cp LICENSE build/

cd build

npm publish

cd ..
