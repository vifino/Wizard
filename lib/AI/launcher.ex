defmodule AI do
	import Wizard

	def enable do
		Global.put(AIs, [])
		command "aictl enable #(.*)", fn (speaker, chan, socket, args) ->
			if speaker == owner do
				ai = AIScoring.new
				Global.get(AIs) |> Enum.into([{"##{Enum.at(args, 0)}", ai}]) |> Global.puts(AIs)
				"Enabled AI in ##{Enum.at(args, 0)}"
			end
		end
		command "ai (.*)", fn (speaker, chan, socket, args) ->
			Enum.each(Global.get(AIs), fn({ch, ai})->
				if ch == chan do
					IRC.msg(socket, chan, AIScoring.think(ai, Enum.at(args, 0)))
				end
			end)
		end
		hook ~r/:(.*?)!(.*?)@(.*) PRIVMSG (.*) :(.*)/i, fn(socket, _phrase, args) ->
			IO.puts "AI hook"
			Global.get(AIs)
			|> Enum.each(fn({chan, ai})->
				IO.puts chan
				if Enum.at(args,3) == chan do
					IO.puts "Learning in #{chan}: #{Enum.at(args, 4)}"
					AIScoring.learn(ai, Enum.at(args,4), 0)
				end
			end)
		end
	end
end
