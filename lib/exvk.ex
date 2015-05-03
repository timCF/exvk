defmodule Exvk do
  use Application

  # See http://elixir-lang.org/docs/stable/elixir/Application.html
  # for more information on OTP Applications
  def start(_type, _args) do
    import Supervisor.Spec, warn: false

    children = [
      # Define workers and child supervisors to be supervised
      # worker(Exvk.Worker, [arg1, arg2, arg3])
    ]

    # See http://elixir-lang.org/docs/stable/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Exvk.Supervisor]
    Supervisor.start_link(children, opts)
  end

  def timeout, do: :timer.sleep(333)

end

defmodule Exvk.HTTP do
  defmacro __using__(_) do
    quote do
      use Httphex,  [
                      host: "https://api.vk.com/method", 
                      opts: [],
                      encode: :json,
                      decode: :json,
                      gzip: false
                    ]
      defp filter_nil(map) when is_map(map) do
        HashUtils.filter_v(map, &(&1 != nil))
      end
    end
  end
end
