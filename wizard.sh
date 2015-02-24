#!/usr/bin/bash
export ERL_COMPILER_OPTIONS="[native,{hipe, [o3]}]"
elixir --sname Wizard --erl "+K true" -S mix run --no-halt
