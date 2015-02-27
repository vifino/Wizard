defmodule Utils do
	@doc "Runs the string `command` as a shell command and returns the result."
	def sh(command) do
		to_string(:os.cmd(to_char_list(command)))
	end
end
