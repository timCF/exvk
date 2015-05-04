defmodule Exvk.Friends do
	use Exvk.HTTP

	def get(uid, token \\ nil, proxy \\ nil) when is_integer(uid) do
		Exvk.timeout
		case %{user_id: uid, access_token: token}
				|> filter_nil
					|> http_get(["friends.get"], get_opts(proxy)) do
			%{response: lst} when is_list(lst) ->
				case Enum.all?(lst, &is_integer/1) do
					true -> lst
					false -> {:error, "Parsed wrong ans from vk #{inspect lst}"}
				end
			error -> {:error, "Unparsable ans from vk #{inspect error}"}
		end
	end

end