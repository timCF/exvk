defmodule Exvk.Groups do
	use Exvk.HTTP
	require Logger

	def getMembers(gid, token \\ nil) when is_integer(gid), do: %{gid: gid, access_token: token} |> filter_nil |> getMembers_inner([], 1000)
	defp getMembers_inner(fields, res, offset) do
		case http_get(fields, ["groups.getMembers"]) do
			%{response: %{users: []}} -> res
			%{response: %{users: lst}} when is_list(lst) -> getMembers_inner(fields, Enum.reduce(lst, res, &parse_members/2), offset+1000)
			error -> {:error, "Unparsable ans from vk #{inspect error}"}
		end
	end
	defp parse_members(el, res) when is_integer(el), do: [el|res]
	defp parse_members(el, res) do
		Logger.error "#{__MODULE__} : "
	end

end