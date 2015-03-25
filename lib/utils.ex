defmodule Utils do
	@compile {:inline}

	# Math related stuff.
	def reseed_rng do
		<< a :: 32, b :: 32, c :: 32 >> = :crypto.rand_bytes(12)
		:random.seed(a,b,c)
		:ok
	end

	def rng() do
		:random.uniform
	end

	def rng(seed) do
		:random.uniform(seed)
	end

	def to_number(val) do
		num = case val =~ "." do
			true  -> Float.parse val
			false -> Integer.parse val
		end

		case num do
			:error   -> nil
			{num, _} -> num
		end
	end

	# Eval stuff
	def eval(code, valmap \\ []) do
		elem(Code.eval_string(code, valmap), 0)
	end
	def eval_ex(code, valmap \\ []) do
		eval(code, valmap)
	end
	def eval_erl(str, valmap \\ []) do
		{:ok, tokens, _} = :erl_scan.string(to_char_list(str))
		{ret, tmp} = :erl_parse.parse_exprs(tokens)
		if ret == :ok do
			valmap = Enum.map(valmap, fn({k, v}) ->
				if is_atom(k) and (to_string(k) == String.capitalize(to_string(k))) do
					{k, v}
				else
					{String.to_atom(String.capitalize(to_string(k))), v}
				end
			end)
			{_, value, _} = :erl_eval.expr(hd(tmp), valmap)
			{:ok, value}
		else
			{:error, elem(tmp, 2)}
		end
	end

	# Erlang pretty-printer. Like inspect. Just erlangs way of representing the data, not elixir's.
	def pp(x) do
		:io_lib.format("~p", [x])
		|> :lists.flatten
		|> :erlang.list_to_binary
	end

	@doc "IO.puts inspect(x)"
	def dbg(x) do
		IO.puts inspect(x)
	end

	@doc "Runs the string `command` as a shell command in /bin/sh and returns the result."
	def sh(command) when is_bitstring command do
		if String.strip(command) != "" do
			to_string(:os.cmd(to_char_list(command)))
		end
	end
	@doc "Runs the string `command` as a shell command with `pipe_input` piped into it and returns the result."
	def sh(pipe_input, command) when is_bitstring(pipe_input) and is_bitstring(command) do
		if String.strip(command) != "" do
			if pipe_input != "" do
				IO.puts "echo -n #{quote_str pipe_input} | #{command}"
				sh("echo -n #{quote_str pipe_input} | #{command}")
			else
				sh(command)
			end
		end
	end

	@doc "Runs the string `command` as a system command without a shell."
	def nosh(command) when is_bitstring command do
		if String.strip(command) != "" do
			[cmd | opts] = OptionParser.split(command)
			elem(System.cmd(cmd, opts), 0)
		end
	end

	defp quote_str(str) do
		str = str
			|> replace("\"", "\\\"")
			|> replace("\\", "\\\\")
		"\"" <> str <> "\""
	end

	def replace(source, str, replacement) do
		regex = if Regex.regex? str do
			str
		else
			Regex.compile!(Regex.escape(str))
		end
		Regex.replace(regex, source, replacement)
	end
end
