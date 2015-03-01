#!/usr/bin/bash
export ERL_COMPILER_OPTIONS="[native, {hipe, [o3, to_llvm]}]"
elixir --sname Wizard --erl "+K true" -S mix run
