defmodule Wizard do
  use Application

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

  def command(phrase, func) do
      { :ok, pattern } = Regex.compile(phrase)
      Commands.add({ pattern, func })
  end

	defmacro cmd(shrtfnc) do
		quote do
			fn(speaker, _chan, _socket) ->
				(&(unquote(shrtfnc))).(speaker)
			end
		end
	end

	defmacro cmdc(shrtfnc) do
		quote do
			fn(_speaker, chan, _socket) ->
				(&(unquote(shrtfnc))).(chan)
			end
		end
	end

	defmacro cmda(shrtfnc) do
		quote do
			fn(_speaker, _chan, _socket, args) ->
				(&(unquote(shrtfnc))).(args)
			end
		end
	end

	defmacro cmdn(shrtfnc) do
		quote do
			fn(_speaker, _chan, _socket) ->
				unquote(shrtfnc)
			end
		end
	end

	defmacro cmdna(shrtfnc) do
		quote do
			fn(_speaker, _chan, _socket, _args) ->
				unquote(shrtfnc)
			end
		end
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
