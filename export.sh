#!/bin/bash

godot ./game/project.godot --headless --export-release Web ../exports/html/index.html
cd exports/html
zip -r -FS opm.zip *
