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

	@doc "Runs the string `command` as a shell command and returns the result."
	def sh(command) do
		to_string(:os.cmd(to_char_list(command)))
	end

	def sh(pipe_input, command) when is_bitstring pipe_input do
		to_string(:os.cmd(to_char_list("echo -n #{inspect pipe_input} | #{command}")))
	end
end
