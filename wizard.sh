#!/usr/bin/bash
export ERL_COMPILER_OPTIONS="[native, {hipe, [o3, to_llvm]}]"
mix compile || exit 1
elixir --sname Wizard --erl "+K true" -S mix run -- $@
