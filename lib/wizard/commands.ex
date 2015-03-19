defmodule Commands do
	@name { :global, __MODULE__ }

	def start_link do
		Agent.start_link( fn-> HashSet.new end, name: @name )
	end

	@doc "Adds a command."
	def add(command) do
		Agent.update(@name, fn(set) -> Set.put(set, command) end)
	end

	@doc "Finds the matching command for `phrase`."
	def find(phrase) do
		set = Agent.get(@name, fn(set) -> set end)
		Enum.find(set, fn ({ pattern, _ }) -> Regex.match?(pattern, phrase) end)
	end

	def run(socket, speaker_name, chan, ret) do
		command = Commands.find(Enum.at(ret, 1))
		if command do
			pattern = elem(command, 0)
			func = elem(command, 1)
			args = Regex.scan(pattern, Enum.at(ret, 1), capture: :all_but_first)
			args = Enum.filter(args, &((Enum.count &1) > 0))

			try do
				if (Enum.count(args) > 0) do
					result = func.(speaker_name, chan, socket, Enum.at(args, 0))
				else
					result = func.(speaker_name, chan, socket)
				end
				IRC.msg(socket, chan, result)
			rescue
				e -> IRC.msg(socket, chan, "Error: #{inspect e}")
			end
		end
	end
end
