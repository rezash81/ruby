#! /usr/bin/env bash

echo "Droping Database"
bin/rake db:drop
echo "Creating new Database"
bin/rake db:create
echo "Migrating Database"
bin/rake db:migrate
echo "Seeding Database"
bin/rake db:seed
