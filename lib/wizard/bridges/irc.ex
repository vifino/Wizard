defmodule Bridge.IRC do
	@name { :global, __MODULE__ }

	@doc "Spawns the connection to the server and returns the socket."
	def spawn(server, port, nickname, pass \\ nil) do
		#serverdata = serverinfo
		#server     = elem(serverdata, 0)
		#port       = elem(serverdata, 1)
		#nickname   = elem(serverdata, 2)

		{ :ok, socket } = :gen_tcp.connect(:erlang.binary_to_list(server), port, [:binary, {:active, false}])
		:ok = transmit(socket, "NICK #{nickname}")
		:ok = transmit(socket, "USER #{nickname} #{server} #{nickname} :#{nickname}")
		if pass do
				:ok = transmit(socket, "PASS :#{pass}")
		end
		#run(socket)
		socket
	end

	@doc "Main processing loopMain processing loop.."
	def run(socket, nick, channels) do
		running = true
		matcher = ~r/(.*)?\r\n/
		try do
			case :gen_tcp.recv(socket, 0) do
				{ :ok, data } ->
					res = Regex.scan(matcher, data) |> Enum.map(&(Enum.at(&1, 1)))
					process(socket, res, nick, channels, 0)
				{ :error, :closed } ->
					running = false
					IO.puts "The client closed the connection..."
			end
		rescue
			e -> IO.puts inspect(e)
		end
		if running do
			run(socket, nick, channels)
		end
	end

	def process(socket, res, nick, channels, item) do
		if Enum.at(res, item) do
			process(socket, Enum.at(res, item, nick), nick, channels)
			process(socket, res, nick, channels, item + 1)
		end
	end

	def process(socket, data, nick, channels) do
		ping             = ~r/^PING/
		motd_end         = ~r/^:(.*?) 376 (.*?)\/MOTD/
		{ :ok, command } = Regex.compile("^#{nick}: (.*)$")
		message_matcher  = ~r/^:(.*?)!(.*?)@(.*?) PRIVMSG (.*?) :(.*)$/

		IO.puts "<-- #{data}"

		if Regex.match?(motd_end, data), do: initialize(socket, channels, 0)

		if Regex.match?(ping, data), do: pong(socket, data)

		if Regex.match?(message_matcher, data) do
			Task.async(fn() ->
				Utils.reseed_rng
				msgdata = Regex.run(message_matcher, data)
				if Enum.at(msgdata, 0) do
					speaker_name = Enum.at(msgdata, 1)
					chan = Enum.at(msgdata, 4)
					content = Enum.at(msgdata, 5)

					ret = Regex.run(command, content)
					if ret do
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
								msg(socket, chan, result)
							rescue
								e -> msg(socket, chan, "Error: #{inspect e}")
							end
						end
					end
				end
			end)
		end
		Task.async(fn() ->
			Utils.reseed_rng
			transmit(socket, Hooks.run(socket, data))
		end)
	end

	@doc "Sends `msg` to the server."
	def transmit(socket, msg) do
		if is_bitstring msg do
			IO.puts "--> #{msg}"
			:gen_tcp.send(socket, "#{msg}\r\n")
		else
			if is_list msg do
				transmit(socket, msg, 0)
			end
		end
	end
	@doc "Loops over `msg` and sends the messages containing it."
	def transmit(socket, msg, index) do
		if Enum.at(msg, index) do
			transmit(socket, Enum.at(msg, index))
			transmit(socket, msg, index + 1)
		end
	end
	@doc "Message `msg` to `channel`, which is either a Channel or a User."
	def msg(socket, channel, msg) do
		#responder = fn
		#	{ channel } -> transmit(socket, "PRIVMSG #{channel} :#{msg}")
		#	{ channel, password } -> transmit(socket, "PRIVMSG #{channel} :#{msg}")
		#end

		transmit(socket, "PRIVMSG #{channel} :#{msg}")
	end

	def initialize(socket, channels, index) do
		serverdata = serverinfo
		if elem(serverdata, 4) do # Acc and password is there.
			:ok = msg(socket, "NickServ", "identify #{elem(serverdata, 3)} #{elem(serverdata, 4)}")
		end
		join_channels(socket, channels, index)
	end

	def join_channels(socket, channels, index \\ 0) do
		if Enum.at(channels, index) do
			chan = Enum.at(channels, index)
			join_channel(socket, chan)
			join_channels(socket, channels, index + 1)
		end
	end

	def join_channel(socket, chan) do
		tmp = chan
		joiner = fn
			{ channel } -> transmit(socket, "JOIN #{ channel }")
			{ channel, password } -> transmit(socket, "JOIN #{ channel } #{ password }")
		end
		if is_bitstring tmp do
			tmp = { tmp }
		end
		joiner.(tmp)
	end

	def pong(socket, data) do
		server = Enum.at(Regex.split(~r/\s/, data), 1)
		transmit(socket, "PONG #{ server }")
	end

	def config do
		{ :ok, config } = :application.get_env(:wizard, :conf)
		config
	end

	def owner do
		Enum.at(config, 0)
	end

	def serverinfo do
		Enum.at(config, 1)
	end

	def bot_name do
		elem(serverinfo, 2)
	end

	def channel_data do
		Enum.at(config, 2)
	end
end
