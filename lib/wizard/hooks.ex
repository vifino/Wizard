defmodule Hooks do
	@name { :global, __MODULE__ }

	def start_link do
		Agent.start_link( fn-> HashSet.new end, name: @name )
	end

	@doc "Adds a hook."
	def add(command) do
		Agent.update(@name, fn(set) -> Set.put(set, command) end)
	end

	@doc "Finds the matching hooks for `phrase`."
	def find(phrase) do
		set = Agent.get(@name, fn(set) -> set end)
		Enum.filter(set, fn ({ pattern, _ }) -> Regex.match?(pattern, phrase) end)
	end

	@doc "Run all hooks matching `phrase`."
	def run(socket, phrase) do
		matching = find phrase
		exec(socket, phrase, matching)
	end

	def exec(_socket, _phrase, found) when found == [] do
		nil
	end

	def exec(socket, phrase, found) do
		exec(socket, phrase, found, 0)
	end

	def exec(socket, phrase, found, index, retdata \\ []) do
		if Enum.at(found, index) do
			ret = eval(socket, phrase, Enum.at(found, index))
			exec(socket, phrase, found, index + 1, Enum.concat(retdata, [ret]))
		end
	end

	def eval(socket, phrase, found)do
		{ regex, fun } = found
		args = Regex.scan(regex, phrase, capture: :all_but_first) |> Enum.at(0)
		if (Enum.count(args) > 0) do
			fun.(socket, phrase, args)
		else
			fun.(socket, phrase)
		end
	end
end
