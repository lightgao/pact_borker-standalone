#!/bin/bash
set -e

# Figure out where this script is located.
SELFDIR="`dirname \"$0\"`"
SELFDIR="`cd \"$SELFDIR\" && pwd`"

# Tell Bundler where the Gemfile and gems are.
export BUNDLE_GEMFILE="$SELFDIR/lib/vendor/Gemfile"
unset BUNDLE_IGNORE_CONFIG

# Run the actual app using the bundled Ruby interpreter, with Bundler activated.
cd "$SELFDIR" && exec "lib/ruby/bin/ruby" -rbundler/setup "lib/ruby/bin.real/thin" --address "0.0.0.0" --port "8080" --environment "production" --tag "pact-broker" --rackup "config.ru" --daemonize "$@"
