defmodule Exvk.Groups do
	use Exvk.HTTP
	require Logger

	def getMembers(gid, token \\ nil) when is_integer(gid), do: %{gid: gid, access_token: token, offset: 0} |> filter_nil |> getMembers_inner([])
	defp getMembers_inner(fields, res) do
		case http_get(fields, ["groups.getMembers"]) do
			%{response: %{users: []}} -> res
			%{response: %{users: lst}} when is_list(lst) -> 
				Map.update!(fields, :offset, &(&1+1000)) 
				|> getMembers_inner(Enum.reduce(lst, res, &parse_members/2))
			error -> {:error, "Unparsable ans from vk #{inspect error}"}
		end
	end
	defp parse_members(el, res) when is_integer(el), do: [el|res]
	defp parse_members(el, res) do
		Logger.error "#{__MODULE__} : got unexpected user #{inspect(el)}"
		res
	end

end