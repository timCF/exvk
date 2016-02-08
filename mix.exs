defmodule Exvk.Mixfile do
  use Mix.Project

  def project do
    [app: :exvk,
     version: "0.0.1",
     #elixir: "~> 1.0.0",
     deps: deps]
  end

  # Configuration for the OTP application
  #
  # Type `mix help compile.app` for more information
  def application do
    [applications:  [
                      :logger,

                      :maybe,
                      :httphex,
                      :tinca,
                      :exutils,
                      :hashex,
                      :maybe,
                      :silverb
                    ],
     mod: {Exvk, []}]
  end

  # Dependencies can be Hex packages:
  #
  #   {:mydep, "~> 0.3.0"}
  #
  # Or git/path repositories:
  #
  #   {:mydep, git: "https://github.com/elixir-lang/mydep.git", tag: "0.1.0"}
  #
  # Type `mix help deps` for more examples and options
  defp deps do
    [
      {:maybe, github: "timCF/maybe"},
      {:httphex, github: "timCF/httphex"},
      {:tinca, github: "timCF/tinca"},
      {:exutils, github: "timCF/exutils"},
      {:hashex, github: "timCF/hashex"},
      {:maybe, github: "timCF/maybe"},
      {:silverb, github: "timCF/silverb"}
    ]
  end
end
