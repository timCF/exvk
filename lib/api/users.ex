defmodule Exvk.Users do
	use Exvk.HTTP
	require Logger

	defp additional_fields do
		"sex,bdate,city,country,photo_50,photo_100,photo_200_orig,photo_200,photo_400_orig,photo_max,photo_max_orig,photo_id,online,online_mobile,domain,has_mobile,contacts,connections,site,education,universities,schools,can_post,can_see_all_posts,can_see_audio,can_write_private_message,status,last_seen,relation,relatives,counters,screen_name,maiden_name,timezone,occupation,activities,interests,music,movies,tv,books,games,about,quotes,personal,friends_status"
	end
	
	def get(users, token \\ nil) when is_list(users) do
		case Enum.all?(users, &is_integer/1) do
			true -> get_inner(users, token, [])
			false -> {:error, "Expected list of ints, got #{inspect users}"}
		end
	end
	defp get_inner([], _token, res), do: Enum.filter(res, &(&1 != :failed))
	defp get_inner(users, token, res) do
		{todo, rest} = Enum.split(users, 1000)
		case %{user_ids: Enum.join(todo, ","), fields: additional_fields, access_token: token}
				|> filter_nil
					|> http_get("users.get") do
			%{response: lst} when is_list(lst) -> 
				get_inner(rest, token, Enum.map(lst, &decode_user/1) ++ res)
			error -> 
				Logger.error "#{__MODULE__} : unparsable ans from vk #{inspect error}, ignore"
				get_inner(rest, token, res)
		end
	end

	defp decode_user(map = %{uid: _, first_name: _, last_name: _}), do: map
	defp decode_user(some) do
		Logger.error "#{__MODULE__} : unexpected user struct #{inspect some}"
		:failed
	end

end