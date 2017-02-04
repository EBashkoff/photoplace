#!/usr/bin/env bash
bundle exec puma -e production -b 'unix:///home/eric/rails_apps/photoplace/shared/tmp/sockets/puma.sock'
