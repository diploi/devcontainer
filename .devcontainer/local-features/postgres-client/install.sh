#!/usr/bin/env bash

set -eax

apt-get update -y
apt-get -y install --no-install-recommends postgresql-client