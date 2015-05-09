defmodule Exvk.Dicts do
	use Silverb, [
					{"@timeout", :timer.hours(72)}
				 ]
	require Logger

	def maybe_update do
		new_stamp = Exutils.makestamp
		case Exvk.Tinca.get(:updated, :exvk_dicts) do
			some when ((some + @timeout) < new_stamp) ->
				#Exvk.Dicts.Countries.update
				#Exvk.Dicts.Cities.update
				Exvk.Tinca.put(Exutils.makestamp, :updated, :exvk_dicts)
			_ -> :ok
		end
	end

	defmodule Countries do
		use Silverb
		use Exvk.HTTP
		def update(res \\ [], offset \\ 0) do
			:timer.sleep(333)
			case http_get(%{need_all: 1, offset: offset, count: 1000}, ["database.getCountries"]) do
				%{response: lst} when is_list(lst) -> 
					case Enum.all?(lst, &(Enum.member?(res, &1))) do
						true -> Enum.each(lst++res, fn(%{cid: id, title: title}) -> Exvk.Tinca.put(title, id, :exvk_countries) end)
						false -> update(lst++res, offset+1000)
					end
				error -> Logger.error "#{__MODULE__} error #{inspect error}"
			end
		end
		def get(id), do: Exvk.Tinca.get(id, :exvk_countries)
	end

	#
	#	this function is long
	#
	defmodule Cities do
		use Silverb
		use Exvk.HTTP
		def update do
			Exvk.Tinca.keys(:exvk_countries)
			|> Enum.each(&(update_proc(&1, [])))
		end
		defp update_proc(coutry, res, offset \\ 0) do
			:timer.sleep(333)
			case http_get(%{need_all: 1, country_id: coutry, offset: offset, count: 1000}, ["database.getCities"]) do
				%{response: lst} when is_list(lst) ->
					case Enum.all?(lst, &(Enum.member?(res, &1))) do
						true -> Enum.each(lst++res, fn(%{cid: id, title: title}) -> Exvk.Tinca.put(title, "#{coutry}:#{id}", :exvk_cities) end)
						false -> update_proc(coutry, lst++res, offset+1000)
					end
				error -> Logger.error "#{__MODULE__} error #{inspect error}"
			end
		end
		def get(coutry, city), do: Exvk.Tinca.get("#{coutry}:#{city}", :exvk_cities)
	end

	defmodule Platforms do
		def get(num) do
			case num do
				1 -> "mobile"
				2 -> "iphone"
				3 -> "ipad"
				4 -> "android"
				5 -> "wphone"
				6 -> "windows"
				7 -> "web"
				_ -> ""
			end
		end
	end

	defmodule Relation do
		def get(num) do
			case num do
				1 -> "не женат/не замужем"
				2 -> "есть друг/есть подруга"
				3 -> "помолвлен/помолвлена"
				4 -> "женат/замужем"
				5 -> "всё сложно"
				6 -> "в активном поиске"
				7 -> "влюблён/влюблена"
				_ -> "не указано"
			end
		end
	end

	defmodule SmokingAlco do
		def get(num) do
			case num do
				1 -> "резко негативное"
				2 -> "негативное"
				3 -> "нейтральное"
				4 -> "компромиссное"
				5 -> "положительное"
				_ -> "не указано"
			end
		end
	end

	defmodule Political do
		def get(num) do
			case num do
				1 -> "коммунистические"
				2 -> "социалистические"
				3 -> "умеренные"
				4 -> "либеральные"
				5 -> "консервативные"
				6 -> "монархические"
				7 -> "ультраконсервативные"
				8 -> "индифферентные"
				9 -> "либертарианские"
				_ -> "не указано"
			end
		end
	end

end