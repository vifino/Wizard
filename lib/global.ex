defmodule Global do
	@name { :global, __MODULE__ }
	# Global storage of data. KV thingie.
	def init do
		Agent.start_link(fn-> HashDict.new end, name: @name)
	end

	def close do
		Agent.stop(@name)
	end

	def put(key, val) do
		Agent.update(@name, fn(dict) -> HashDict.put(dict, key, val) end)
	end

	def puts(val, key) do
		Agent.update(@name, fn(dict) -> HashDict.put(dict, key, val) end)
	end

	def get(key) do
		Agent.get(@name, fn(dict) -> HashDict.get(dict, key) end)
	end

	def del(key) do
		Agent.update(@name, fn(dict) -> HashDict.delete(dict, key) end)
	end
	def size do
		Agent.get(@name, fn(dict) -> HashDict.size(dict) end)
	end
end
