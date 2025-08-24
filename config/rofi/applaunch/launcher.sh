#!/usr/bin/env bash

dir="$HOME/.config/rofi/applaunch"
theme='my-style'

rofi \
    -show drun \
    -DPI 1.5 \
    -theme ${dir}/${theme}.rasi
