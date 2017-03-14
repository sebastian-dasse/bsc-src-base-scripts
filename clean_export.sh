#!/usr/bin/env bash

find . -type d -name node_modules -exec rm -rf {} 2>/dev/null \;
find . -type d -name target -exec rm -rf {} 2>/dev/null \;
find . -type d -empty -exec rm -rf {} 2>/dev/null \;

echo "Ready for export. (Deleted all empty directories and those named 'target' and 'node_modules'.)"