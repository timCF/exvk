defmodule Exvk.Auth do
	use Silverb
	use Exvk.HTTP

	def get_my_name(token, proxy \\ nil) do
		Exvk.timeout
		case %{access_token: token} |> http_get("users.get", get_opts(proxy)) do
			%{response: [%{first_name: name, uid: uid}]} when (is_binary(name) and is_integer(uid)) -> %{first_name: name, uid: uid}
			error -> {:error, error}
		end
	end

	def get_permissions(token, proxy \\ nil) do
		Exvk.timeout
		case %{access_token: token} |> http_get("account.getAppPermissions", get_opts(proxy)) do
			%{response: response} -> response
			error -> {:error, error}
		end
	end

end
