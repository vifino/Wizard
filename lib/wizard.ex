defmodule Wizard do
  use Application

	@doc "Start the IRC Connection."
	def start(_type, _args) do
    import Supervisor.Spec, warn: false
    children = []
    opts = [strategy: :one_for_one, name: Wizard.Supervisor]

    Commands.start_link
		socket = Bridge.IRC.spawn
    irc_con = Task.async(Bridge.IRC, :run, [socket])

    Code.require_file("wizard.exs")

    Supervisor.start_link(children, opts)

		Task.await(irc_con, :infinity)
  end

	@doc "Adds a command matched by string `phrase`, which is a regex. Runs `func` if it matched."
  def command(phrase, func) do
      { :ok, pattern } = Regex.compile(phrase)
      Commands.add({ pattern, func })
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
