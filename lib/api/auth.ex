defmodule Exvk.Auth do
	use Exvk.HTTP

	def get_my_name(token) do
		Exvk.timeout
		case %{access_token: token} |> http_get("users.get") do
			%{response: [%{first_name: name, uid: uid}]} when (is_binary(name) and is_integer(uid)) -> 
				"#{name}_#{uid}"
			error -> 
				{:error, error}
		end
	end

end