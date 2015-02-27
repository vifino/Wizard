defmodule Utils do
	@compile {:inline}
	#@on_load :reseed_rng

  def reseed_rng do
		:random.seed(:erlang.now)
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
end
