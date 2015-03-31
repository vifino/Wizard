defmodule AIScoring do
	import Utils
	# Scoring AI.
	# Memory is [{text, prio, reply}]

	def new(memory \\ KVStore.new) do
		KVStore.put(memory, "lastSentence", nil)
		KVStore.put(memory, "memory", [])
		KVStore.put(memory, "bestScore", 999999)
	end

	#def learn(memory, question, answer, prio \\ 0) do
	#	new_word(memory, question, prio, answer)
	#end

	def learn(memory, sentence, prio \\ 0) do
		last = KVStore.get(memory, "lastSentence")
		if last != nil do
			KVStore.put(memory, "memory", new_word(KVStore.get(memory, "memory"), last, prio, sentence))
		end
		KVStore.put(memory, "lastSentence", sentence)
	end

	def think(memory, sentence) do
		#if is_port memory do
		ret = find_answer(memory, sentence)
		if ret != nil do
			if KVStore.get(memory, "bestScore") <= 7 do
				KVStore.put(memory, "lastSentence", elem(ret, 2))
				elem(ret, 2)
			else
				KVStore.put(memory, "lastSentence", elem(ret, 0))
				elem(ret, 0)
			end
		end
		#else
		#	if length(memory) != 0 do
		#		{bestScore, {text, priority, reply}} = find_answer(memory, sentence)
		#		if bestScore <= 7 do
		#			reply
		#		else
		#			text
		#		end
		#	else
		#		nil
		#	end
		#end
	end

	def find_answer(memory, input) do
		scores = Enum.map(KVStore.get(memory, "memory"), fn({text, _, _})->
			score(text, input)
		end)
		best = Enum.min scores
		KVStore.put(memory, "bestScore", best)
		Enum.with_index(scores)
		|> Enum.map(fn({val, index})->
			if val == best do
				Enum.at(KVStore.get(memory, "memory"), index)
			end
		end)
		|> Enum.at(0)
	end

	def score(a, b) do
		if not (len(b) == 0 or len(a) == 0) do
			matrix = KVStore.new
			0..len(b) |> Enum.each(fn(x) ->
				KVStore.put(matrix, x, new_mtx(x))
			end)
			#IEx.pry
			0..len(a) |> Enum.each(&(
				mtx(matrix, 0, &1, &1)
			))
			#IEx.pry
			1..len(b) |> Enum.each(fn(i) ->
				1..len(a) |> Enum.each(fn(j) ->
					if at(b, i-1) == at(a, j-1) do
						mtx(matrix, i, j, mtxa(matrix, i-1, j-1))
					else
						a = mtxa(matrix, i-1, j-1) + 1
						b = mtxa(matrix, i,   j-1) + 1
						c = mtxa(matrix, i-1, j  )	 + 1
						mtx(matrix, i, j,
							min(a, min(b, c))
						)
					end
				end)
			end)
			#IEx.pry
			res = mtxa(matrix, len(b), len(a))
			0..len(b) |> Enum.each(fn(mat) ->
				get(matrix, mat) |> KVStore.close
			end)
			KVStore.close(matrix)
			res
		else
			if len(a) == 0 do
				len(b)
			end
			if len(b) == 0 do
				len(a)
			end
		end
	end

	# Handy little aliases.
	def len(str) do
		String.length(str)
	end
	def at(str, index) do
		String.at(str, index)
	end
	def mtx(matrix, k, v) do
		#submatrix = KVStore.get(matrix, k)
		KVStore.put(matrix, k, v)
		#KVStore.put(matrix, k, submatrix)
	end
	def mtx(matrix, x, y, v) do
		res = get(matrix, x)
		if res != nil do
			mtx(res, y, v)
		end
	end
	def mtxa(matrix, x, y) do
		get(matrix, x)
		|> get(y)
	end
	def new_mtx(x) do
		KVStore.new
		|> KVStore.put(0, x)
	end
	def get(kvstore, key) do
		KVStore.get(kvstore, key)
	end
	def word(text, prio, reply) do
		{text, prio, reply}
	end
	def new_word(memory \\ [], text, prio, reply) do
		Enum.concat(memory, [word(text, prio, reply)])
	end
end
