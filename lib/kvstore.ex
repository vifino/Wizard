defmodule KVStore do
	@compile {:inline}

	def new do
		{:ok, agent} = Agent.start_link(fn-> HashDict.new end)
		agent
	end

	def close(agent) do
		Agent.stop(agent)
	end

	def put(agent, key, val) do
		Agent.update(agent, fn(dict) -> HashDict.put(dict, key, val) end)
		agent
	end

	def get(agent, key) do
		Agent.get(agent, fn(dict) -> HashDict.get(dict, key) end)
	end

	def del(agent, key) do
		Agent.update(agent, fn(dict) -> HashDict.delete(dict, key) end)
		agent
	end
	def size(agent) do
		Agent.get(agent, fn(dict) -> HashDict.size(dict) end)
	end
end
