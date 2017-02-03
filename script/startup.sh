#!/usr/bin/env bash
bundle exec puma -e production -b 'unix:///home/ubuntu/rails_apps/photoplace/shared/tmp/sockets/puma.sock'
