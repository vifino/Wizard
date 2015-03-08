defmodule Utils do
	@compile {:inline}
	#@on_load :reseed_rng

  def reseed_rng do
		#:random.seed(:erlang.now)
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

	@doc "Runs the string `command` as a shell command in /bin/sh and returns the result."
	def sh(command) when is_bitstring command do
		if String.strip(command) != "" do
			to_string(:os.cmd(to_char_list(command)))
		end
	end
	@doc "Runs the string `command` as a shell command in bash and returns the result."
	def bash(command) when is_bitstring command do
		if String.strip(command) != "" do
			elem(System.cmd("bash", ["-c", command], [{:stderr_to_stdout, true}]), 0)
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

	def quote_str(str) do
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
