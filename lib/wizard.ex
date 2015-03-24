defmodule Wizard do
	use Application

	@doc "Start the IRC Connection."
	def start(_type, _args) do
		import Supervisor.Spec, warn: false
		children = []
		opts = [strategy: :one_for_one, name: Wizard.Supervisor]

		Utils.reseed_rng

		Commands.start_link
		Hooks.start_link
		serverdata = IRC.serverinfo
		server     = elem(serverdata, 0)
		port       = elem(serverdata, 1)
		nickname   = elem(serverdata, 2)

		socket = if elem(serverdata, 3) do
			if elem(serverdata, 4) == nil do
				IRC.spawn(server, port, nickname, elem(serverdata, 3))
			else
				IRC.spawn(server, port, nickname, nil)
			end
		end
		irc_con = Task.async(IRC, :run, [socket, nickname, IRC.channel_data])

		Code.require_file("wizard.exs")

		Supervisor.start_link(children, opts)

		Task.await(irc_con, :infinity)
	end

	@doc "Adds a command matched by string `phrase`, which is a regex. Runs `func` if it matched."
	def command(phrase, func) do
		if is_map phrase do
			Commands.add({ phrase, func })
		else
			{ :ok, pattern } = Regex.compile(phrase, "i")
			Commands.add({ pattern, func })
		end
	end

	@doc "Runs `func` if `phrase` matches a received line. (Does not match \"PRIVMSG\"'s or \"PING\"'s)"
	def hook(phrase, func) do
		if is_map phrase do
			Hooks.add({ phrase, func })
		else
			{ :ok, pattern } = Regex.compile(phrase)
			Hooks.add({ pattern, func })
		end
	end

	@doc "Macro for creating `func` for `command`. Behaves like `&`. `&1` is the `speaker`."
	defmacro cmd(shrtfnc) do
		quote do
			fn(speaker, _chan, _socket) ->
				(&(unquote(shrtfnc))).(speaker)
			end
		end
	end

	@doc "Macro for creating `func` for `command`. Behaves like `&`. `&1` is the `chan`."
	defmacro cmdc(shrtfnc) do
		quote do
			fn(_speaker, chan, _socket) ->
				(&(unquote(shrtfnc))).(chan)
			end
		end
	end

	@doc "Macro for creating `func` for `command`. Behaves like `&`. `&1` are the `args`."
	defmacro cmda(shrtfnc) do
		quote do
			fn(_speaker, _chan, _socket, args) ->
				(&(unquote(shrtfnc))).(args)
			end
		end
	end

	@doc "Macro for creating `func` for `command`. Runs the content without arguments. Useful for just plain strings."
	defmacro cmdn(shrtfnc) do
		quote do
			fn(_speaker, _chan, _socket) ->
				unquote(shrtfnc)
			end
		end
	end

	@doc "Macro for creating `func` for `command`. Runs the content without arguments. Useful for just plain strings. Use this if you used capture groups in your regex for command."
	defmacro cmdna(shrtfnc) do
		quote do
			fn(_speaker, _chan, _socket, _args) ->
				unquote(shrtfnc)
			end
		end
	end

	@doc "Returns the config."
	def config do
		{ :ok, config } = :application.get_env(:wizard, :conf)
		config
	end

	@doc "Returns the owner of this bot."
	def owner do
		Enum.at(config, 0)
	end

	@doc "Returns the server info."
	def serverinfo do
		Enum.at(config, 1)
	end

	@doc "Returns the bot's name."
	def bot_name do
		elem(serverinfo, 2)
	end

	@doc "Returns the channels."
	def channel_data do
		Enum.at(config, 2)
	end
end
