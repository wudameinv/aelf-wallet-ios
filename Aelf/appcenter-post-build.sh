#!/usr/bin/env bash
ls -l  /Users/runner/runners/2.170.1/work/1/output/build/export/_XcodeTaskExport_AelfApp/
sudo gem install fir-cli
fir p $APPCENTER_OUTPUT_DIRECTORY/$APP_FILE -T $FIR_TOKEN
