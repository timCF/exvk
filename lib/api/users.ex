defmodule Exvk.Users do
	use Silverb
 	@keys %Exvk.User{} |> HashUtils.keys |> Enum.reduce(HashSet.new, &(HashSet.put(&2,&1)))
	use Exvk.HTTP
	require Logger

	@additional_fields "sex,bdate,city,country,photo_50,photo_100,photo_200_orig,photo_200,photo_400_orig,photo_max,photo_max_orig,photo_id,online,online_mobile,domain,has_mobile,contacts,connections,site,education,universities,schools,can_post,can_see_all_posts,can_see_audio,can_write_private_message,status,last_seen,relation,relatives,counters,screen_name,maiden_name,timezone,occupation,activities,interests,music,movies,tv,books,games,about,quotes,personal,friends_status"
	defp make_user_struct(map = %{}) do
		Map.keys(map)
		|> Stream.filter(&(HashSet.member?(@keys,&1)))
		|> Enum.reduce(%Exvk.User{}, &(Map.put(&2,&1,Map.get(map,&1))))
	end

	#
	#	get
	#

	def get(users, opts \\ [:friends, :groups], token \\ nil, proxy \\ nil) when is_list(users) do
		case Enum.all?(users, &is_integer/1) do
			true -> get_inner(users, opts, token, [], proxy)
			false -> {:error, "Expected list of ints, got #{inspect users}"}
		end
	end
	defp get_inner([], _opts, _token, res, _proxy), do: Enum.filter(res, &(&1 != :failed))
	defp get_inner(users, opts, token, res, proxy) do
		{todo, rest} = Enum.split(users, 1000)
		Exvk.timeout
		case %{user_ids: Enum.join(todo, ","), fields: @additional_fields, access_token: token}
				|> filter_nil
					|> http_get("users.get", get_opts(proxy)) do
			%{response: lst} when is_list(lst) ->
				get_inner(rest, opts, token, Enum.map(lst, &(decode_user(&1, opts, token, proxy))) ++ res, proxy)
			error ->
				Logger.error "#{__MODULE__} : unparsable ans from vk #{inspect error}, ignore"
				get_inner(rest, opts, token, res, proxy)
		end
	end

	defp decode_user(map = %{uid: uid, first_name: _, last_name: _}, opts, token, proxy) when is_integer(uid) do
		Map.put(map, :friends,
			case Enum.member?(opts, :friends) do
				false -> []
				true -> case Exvk.Friends.get(uid, token, proxy) do
							{:error, error} ->  Logger.error inspect(error)
												[]
							friends when is_list(friends) -> friends
						end
			end)
		|> Map.put(:groups,
			case Enum.member?(opts, :groups) do
				false -> []
				true -> case Exvk.Groups.get(uid, token, proxy) do
							{:error, error} ->  Logger.error inspect(error)
												[]
							groups when is_list(groups) -> groups
						end
			end)
		|> Map.update(:counters, %{}, &vals_to_string/1)
		|> add_country_and_city
		|> maybe_update_last_seen
		|> maybe_update_occupation
		|> Map.update(:relation, "", &Exvk.Dicts.Relation.get/1)
		|> Map.update(:relation_partner, %{}, &vals_to_string/1)
		|> maybe_update_alco_smoke
		|> maybe_update_political
		|> maybe_update_personal
		|> Map.update(:sex, "пол не указан",
			fn
				1 -> "женский"
				2 -> "мужской"
				_ -> "пол не указан"
			end)
		|> update_some_maps_to_flat
		|> make_user_struct
	end
	defp decode_user(some, _, _, _) do
		Logger.error "#{__MODULE__} : unexpected user struct #{inspect some}"
		:failed
	end

	defp add_country_and_city(map = %{country: country, city: _}) do
		Map.update!(map, :country, &(Exvk.Dicts.Countries.get(&1)))
		|> Map.update!(:city, &(Exvk.Dicts.Cities.get(country, &1)))
	end
	defp add_country_and_city(map = %{country: _}), do: Map.update!(map, :country, &(Exvk.Dicts.Countries.get(&1)))
	defp add_country_and_city(some), do: some

	defp maybe_update_last_seen(map = %{last_seen: %{platform: platform, time: time}}) when (is_integer(platform) and is_integer(time)) do
		Map.put(map, :last_seen_time, time)
		|> Map.put(:last_seen_platform, Exvk.Dicts.Platforms.get(platform))
	end
	defp maybe_update_last_seen(some), do: some

	defp maybe_update_occupation(map = %{occupation: %{name: name, type: type}}) when (is_binary(name) and is_binary(type)) do
		Map.put(map, :occupation_name, name)
		|> Map.put(:occupation_type, type)
	end
	defp maybe_update_occupation(map = %{}), do: map


	defp maybe_update_alco_smoke(map = %{personal: personal}) when is_map(personal) do
		Enum.reduce([:alcohol, :smoking], map,
			fn(key, res) ->
				Map.put(res, String.to_atom("personal_#{key}"), Map.get(personal, key) |> Exvk.Dicts.SmokingAlco.get)
			end)
	end
	defp maybe_update_alco_smoke(map), do: map

	defp maybe_update_political(map = %{personal: %{political: pol}}) when is_integer(pol), do: Map.put(map, :personal_political, Exvk.Dicts.Political.get(pol))
	defp maybe_update_political(map), do: map

	defp maybe_update_personal(map = %{personal: personal}) when is_map(personal) do
		Enum.reduce([:inspired_by, :religion], map,
			fn(key, res) ->
				case Map.get(personal, key) do
					some when is_binary(some) -> Map.put(res, String.to_atom("personal_#{key}"), some)
					_ -> res
				end
			end)
	end
	defp maybe_update_personal(map), do: map


	defp update_some_maps_to_flat(map = %{}) do
		Enum.reduce([:relatives, :schools, :universities], map,
			fn(key, res) ->
				case Map.get(res, key) do
					lst when is_list(lst) -> Map.put(res, key, maybe_make_it_flat(lst))
					_ -> Map.put(res, key, %{})
				end
			end)
	end


	defp vals_to_string(enum), do: Enum.reduce(enum,%{},fn({k,v}, res) -> Map.put(res, k, to_string(v)) end)
	defp maybe_make_it_flat([]), do: %{}
	defp maybe_make_it_flat(lst) when is_list(lst) do
		case Enum.all?(lst, &is_map/1) do
			false -> %{}
			true -> Enum.reduce(0..(length(lst)-1), %{},
						fn(el, res) ->
							Enum.at(lst, el)
							|> Enum.reduce(res,
								fn({k,v}, res) ->
									Map.put(res, String.to_atom("#{k}_#{el}"), to_string(v))
								end)
						end)

		end
	end

	#
	#	search
	#

	def search(fields \\ %{}, token \\ nil, proxy \\ nil) do # user can re-define fields
		case check_params(fields) do
			{:error, error} -> {:error, error}
			params = %{} -> Map.merge(params, %{offset: 0, count: 1000, access_token: token})
								|> filter_nil
									|> search_inner([], proxy)
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
	defp search_inner(fields, res, proxy) do
		Exvk.timeout
		case http_get(fields, "users.search", get_opts(proxy)) do
			%{response: []} -> res
			%{response: [int|rest]} when is_integer(int) ->
				uids = Enum.map(rest, fn(%{uid: uid}) -> uid end)
				case Enum.all?(uids, &(Enum.member?(res, &1))) do
					true -> res
					false -> Map.update!(fields, :offset, &(&1+1000))
							 |> search_inner(uids++res, proxy)
				end
			error -> {:error, "#{__MODULE__} : unparsable ans from vk #{inspect error}, ignore"}
		end
	end
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

end
