import Wizard
import Utils

command "say (.*)", cmda(Enum.at(&1, 0))

command "heya", fn (speaker, _chan, _socket) ->
	greetings = [
		"yo", "backatcha", "aight", "hi", "g'day",
	]
	greeting = Enum.at greetings, round(rng ((Enum.count greetings) -1))
	"#{greeting} #{speaker}"
end

command "eval (.*)", fn (speaker, chan, socket, args) ->
	if speaker == owner do
		try do
			inspect elem(Code.eval_string("import Wizard; import Utils; " <> Enum.at(args, 0), [speaker: speaker, chan: chan, socket: socket, args: Enum.at(args,0)]), 0)
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
	Enum.at responses, round(rng ((Enum.count responses) -1))
end

# Funny commands :D
hook ~r/:(.*?)!(.*?)@(.*) PRIVMSG (.*) :(.*?)kick(\s*?)me(.*?)/i, fn(socket, _phrase, args) ->
	Bridge.IRC.transmit(socket, "KICK #{Enum.at(args, 3)} #{Enum.at(args, 0)} :No problem.")
end

hook ~r/:(.*?)!(.*?)@(.*) PRIVMSG (.*) :(.*?)\a(.*?)/i, fn(socket, _phrase, args) ->
	Bridge.IRC.transmit(socket, "KICK #{Enum.at(args, 3)} #{Enum.at(args, 0)} :Put that BELL up yer arse.")
end

# Mod commands.
# Unban: :zsh!zsh@services.esper.net MODE #V +b *!*@host81-158-132-107.range81-158.btcentralplus.com
hook ~r/^:(.*?)!(.*?)@(.*) MODE (.*) \+b (.*)$/, fn(socket, _phrase, args) ->
	#Task.async(fn(socket, args)-> 
		:timer.sleep(1000 * 60 * 10)
		#IO.puts inspect(args)
		Bridge.IRC.transmit(socket, "MODE #{Enum.at(args, 3)} -b #{Enum.at(args, 4)}")
	#end, [socket, args])
end

hook ~r/^:(.*?)!(.*?)@(.*) KICK (.*?) #{Bridge.IRC.bot_name} :(.*)$/, fn(socket, _phrase, args) ->
	Bridge.IRC.transmit(socket, "JOIN #{Enum.at(args, 3)}")
end

command "die", cmd("You first, #{&1}.")
command "quit", cmd("Nice try. After you, #{&1}!")

command "<3", cmdn("What is love? Baby, I'll hurt you! I'll hurt you because I'm a fucking Wizard.")
