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
end
