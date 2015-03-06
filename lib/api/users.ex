defmodule Exvk.Users do
	use Exvk.HTTP
	require Logger

	defp additional_fields do
		"sex,bdate,city,country,photo_50,photo_100,photo_200_orig,photo_200,photo_400_orig,photo_max,photo_max_orig,photo_id,online,online_mobile,domain,has_mobile,contacts,connections,site,education,universities,schools,can_post,can_see_all_posts,can_see_audio,can_write_private_message,status,last_seen,relation,relatives,counters,screen_name,maiden_name,timezone,occupation,activities,interests,music,movies,tv,books,games,about,quotes,personal,friends_status"
	end
	
	#
	#	get
	#
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

	#
	#	search
	#

	defp int_not_nil(some), do: (is_integer(some) and (some > 0))
	defp search_fields_config do
		%{ 
			q: &is_binary/1,
			city: &int_not_nil/1,
			country: &int_not_nil/1,
			hometown: &is_binary/1,
			university_country: &int_not_nil/1,
			university: &int_not_nil/1,
			university_year: &int_not_nil/1,
			university_faculty: &int_not_nil/1,
			university_chair: &int_not_nil/1,
			sex: &(&1 in 0..2),
			status: &(&1 in 1..7),
			age_from: &int_not_nil/1,
			age_to: &int_not_nil/1,
			birth_day: &int_not_nil/1,
			birth_month: &int_not_nil/1,
			birth_year: &int_not_nil/1,
			online: &(&1 in [0,1]),
			has_photo: &(&1 in [0,1]),
			school_country: &int_not_nil/1,
			school_city: &int_not_nil/1,
			school_class: &int_not_nil/1,
			school: &int_not_nil/1,
			school_year: &int_not_nil/1, 
			religion: &is_binary/1,
			interests: &is_binary/1,
			company: &is_binary/1,
			position: &is_binary/1,
			group_id: &int_not_nil/1, 
			from_list: &is_binary/1
		}
	end
	def search(fields \\ %{}, token \\ nil) do # user can re-define fields
		case check_params(fields) do
			{:error, error} -> error
			params = %{} -> Map.merge(params, %{offset: 0, count: 1000, access_token: token})
								|> filter_nil
									|> search_inner
		end
	end
	defp check_params(fields) do
		Map.keys(fields)
			|> Enum.reduce(%{}, 
				fn
				_, {:error, error} -> {:error, error}
				k, resmap ->
					case Map.get(search_fields_config, k) do
						nil -> {:error, "#{__MODULE__} : key #{inspect k} is not supported"}
						func when is_function(func, 1) -> 
							param = Map.get(fields, k)
							case func.(param) do
								true -> Map.put(resmap, k, param)
								false -> {:error, "#{__MODULE__} : wrong param #{inspect(k)} => #{inspect(param)}"}
							end
					end
				end) 
	end
	defp search_inner(fields) do
		case http_get(fields, "users.search") do
			%{response: [c|_]} when is_integer(c) -> c
			error -> {:error, "#{__MODULE__} : unparsable ans from vk #{inspect error}, ignore"}
		end
	end


end