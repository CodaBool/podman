#!/bin/bash
# Human-in-the-loop: one interactive iteration you can watch and steer.
claude --permission-mode acceptEdits "$("$(dirname "$(realpath "$0")")/context.sh")"
