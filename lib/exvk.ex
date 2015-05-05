defmodule Exvk do
  use Application
  use Exvk.Structs
  use Tinca,	[
  					:exvk_cities,
  					:exvk_countries,
  					:exvk_dicts
  				]
  # See http://elixir-lang.org/docs/stable/elixir/Application.html
  # for more information on OTP Applications
  def start(_type, _args) do
    import Supervisor.Spec, warn: false
    Tinca.declare_namespaces
    Tinca.put(0, :updated, :exvk_dicts)
    children = [
      # Define workers and child supervisors to be supervised
      # worker(Exvk.Worker, [arg1, arg2, arg3])
    ]

    # See http://elixir-lang.org/docs/stable/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Exvk.Supervisor]
    Supervisor.start_link(children, opts)
  end

  def timeout do 
  	Exvk.Dicts.maybe_update
  	:timer.sleep(333)
  end

end

defmodule Exvk.HTTP do
  defmacro __using__(_) do
    quote do
      use Httphex,  [
                      host: "https://api.vk.com/method", 
                      opts: [],
                      encode: :json,
                      decode: :json,
                      gzip: false,
                      client: :httpotion
                    ]
      defp filter_nil(map) when is_map(map) do
        HashUtils.filter_v(map, &(&1 != nil))
      end
      defp get_opts(nil), do: %{}
      defp get_opts(bin) when is_binary(bin) do 
      	#%{opts: [proxy: bin]}
      	case String.split(bin, ":") do
			[host, port] -> %{opts: [ibrowse: [proxy_host: host, proxy_port: port |> Maybe.to_integer], timeout: 10000]}
			_ -> %{} 
      	end
      end
    end
  end
end
