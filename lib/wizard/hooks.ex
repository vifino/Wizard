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
	def run(phrase) do
		matching = find phrase
		exec(phrase, matching)
	end
	def exec(_phrase, found) when found == [] do
		nil
	end
	def exec(phrase, found) do
		exec(phrase, found, 0)
	end
	def exec(phrase, found, index, retdata \\ []) do
		if Enum.at(found, index) do
			ret = eval(phrase, Enum.at(found, index))
			retdata = exec(phrase, found, index + 1, Enum.concat(retdata, [ret]))
		end
		retdata
	end
	def eval(phrase, found)do
		{ regex, fun } = found
		args = Regex.scan(regex, phrase, capture: :all_but_first) |> Enum.at(0)
		if (Enum.count(args) > 0) do
			fun.(phrase, args)
		else
			fun.(phrase)
		end
	end
end
