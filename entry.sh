#!/usr/bin/env sh

exec jupyter-lab --notebook-dir=/home/bob/work --no-browser --collaborative --LabApp.token="" --LabApp.password="" --ip=0.0.0.0 --port=8088
