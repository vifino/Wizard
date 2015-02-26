defmodule Utils do
	def sh(command) do
		to_string(:os.cmd(to_char_list(command)))
	end
end
