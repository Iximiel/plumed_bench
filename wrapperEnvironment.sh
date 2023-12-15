#!/bin/bash

command="$@"

# Shell Setup
module restore stdmpi

# Run VTune™ collector
$command

# Postfix script
ls -la $VTUNE_RESULT_DIR
