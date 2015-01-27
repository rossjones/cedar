defmodule Cedar.Mixfile do
  use Mix.Project

  def project do
    [app: :cedar,
     version: "0.0.1",
     elixir: "~> 1.0",
     elixirc_paths: ["lib", "web"],
     compilers: [:phoenix] ++ Mix.compilers,
     deps: deps]
  end

  # Configuration for the OTP application
  #
  # Type `mix help compile.app` for more information
  def application do
    [mod: {Cedar, []},
     applications: [:phoenix, :cowboy, :logger]]
  end

  # Specifies your project dependencies
  #
  # Type `mix help deps` for examples and options
  defp deps do
    [{:phoenix, github: "phoenixframework/phoenix"},
     {:cowboy, "~> 1.0"},
      {:mailgun, "~> 0.0.1"},
      {:httpoison, "~> 0.5"},
      {:twilio, git: "git://github.com/openhealthcare/twilio_erlang.git"},
      {:exrm, "~> 0.14.16"}
    ]
  end
end