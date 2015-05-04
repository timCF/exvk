defmodule Exvk.Groups do
	use Exvk.HTTP
	require Logger

	def getMembers(gid, token \\ nil, proxy \\ nil) when is_integer(gid), do: %{gid: gid, access_token: token, offset: 0} |> filter_nil |> getMembers_inner([], proxy)
	defp getMembers_inner(fields, res, proxy) do
		Exvk.timeout
		case http_get(fields, ["groups.getMembers"], get_opts(proxy)) do
			%{response: %{users: []}} -> Enum.uniq(res)
			%{response: %{users: lst}} when is_list(lst) -> 
				case Enum.all?(lst, &is_integer/1) do
					true -> 
						case Enum.all?(lst, &(Enum.member?(res, &1))) do
							true ->  Enum.uniq(res)
							false -> Map.update!(fields, :offset, &(&1+1000)) 
									 |> getMembers_inner(lst++res, proxy)
						end
					false -> {:error, "Unparsable ans from vk #{inspect lst}"}
				end
			error -> {:error, "Unparsable ans from vk #{inspect error}"}
		end
	end


	def get(uid, token \\ nil, proxy \\ nil) when is_integer(uid), do: %{user_id: uid, offset: 0, count: 1000, access_token: token} |> filter_nil |> get_proc([], proxy)
	defp get_proc(q, res, proxy) do
		Exvk.timeout
		case http_get(q, ["groups.get"], get_opts(proxy)) do
			%{response: []} -> Enum.uniq(res)
			%{response: lst} when is_list(lst) -> 
				case Enum.all?(lst, &is_integer/1) do
					true ->  
						case Enum.all?(lst, &(Enum.member?(res, &1))) do
							true -> Enum.uniq(res)
							false -> Map.update!(q, :offset, &(&1+1000)) |> get_proc(lst++res, proxy)
						end
					false -> {:error, "Unparsable ans from vk #{inspect lst}"}
				end
			error -> {:error, "Unparsable ans from vk #{inspect error}"}
		end
	end

end