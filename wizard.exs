import Wizard

command "say (.*)", cmda(Enum.at(&1, 0))

command "heya", fn (speaker, _chan, _socket) -> 
	greetings = [
		"yo", "backatcha", "aight", "hi", "g'day",
	]
	greeting = Enum.at greetings, round(:random.uniform ((Enum.count greetings) -1))
	"#{greeting} #{speaker}" 
end

command "eval (.*)", fn (speaker, chan, socket, args) ->
	if speaker == owner do
		try do
			inspect elem(Code.eval_string(Enum.at(args, 0), [speaker: speaker, chan: chan, socket: socket, args: Enum.at(args,0)]), 0)
			#"#{Enum.at(args, 0) |> Code.eval_string |> elem(0) |> inspect}"
		rescue
			e -> "Error: #{inspect e}"
		end
	end
end

command "mirror me", cmd(String.reverse(&1))

command "reverse (.*)", cmda(String.reverse(Enum.at(&1,0)))

command "(.*) suck(.*)", cmdna("Doubt it.")

command "(.*)\\?", fn (_speaker, _chan, _socket, _args) ->
	responses = [
		"It is certain.", "It is decidedly so.", "Without a doubt.", "Yes definitely.", "You may rely on it.", 
		"As I see it, yes.", "Most likely.", "Outlook good.", "Yes.", "Signs point to yes.",

		"Reply hazy try again.", "Ask again later.", "Better not tell you now.",
		"Cannot predict now.", "Concentrate and ask again.",

		"Don't count on it.", "My reply is no.", "My sources say no.",
		"Outlook not so good.", "Very doubtful.",
	]
	Enum.at responses, round(:random.uniform ((Enum.count responses) -1))
end

# Funny commands :D
command "die", cmd("You first, #{&1}.")
command "quit", cmd("Nice try. After you, #{&1}!")

command "<3", cmdn("What is love? Baby, I'll hurt you! Hurt you because I'm a fucking Wizard.")
