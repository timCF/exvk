defmodule Exvk.Structs do
	defmacro __using__(_) do
		quote location: :keep do
			use Hashex, [
							__MODULE__.User
						]
			defmodule User do
				defstruct	about: "", 
							activities: "",
							bdate: "",
							books: "",
							can_post: 0,
							can_see_all_posts: 0,
							can_see_audio: 0,
							can_write_private_message: 0,
							city: "", # int -> string from dict
							counters: %{},
							country: "", # int -> string from dict
							domain: "",
							education_form: "",
							education_status: "",
							faculty: 0,
							faculty_name: "",
							first_name: "",
							games: "",
							graduation: 0,
							has_mobile: 0,
							interests: "",
							last_name: "",
							last_seen_time: 0,
							last_seen_platform: "",
							movies: "",
							music: "",
							occupation_name: "",
							occupation_type: "",
							online: 0,
							personal_alcohol: "",
							personal_smoking: "",
							personal_political: "",
							personal_inspired_by: "",
							personal_religion: "",
							photo_100: "",
							photo_200: "",
							photo_200_orig: "",
							photo_400_orig: "",
							photo_50: "",
							photo_id: "",
							photo_max: "",
							photo_max_orig: "",
							quotes: "",
							relation: "",
							relation_partner: %{},
							relatives: %{},
							schools: %{},
							screen_name: "",
							sex: "",
							site: "",
							status: "",
							tv: "",
							uid: 0,
							universities: %{},
							university: 0,
							university_name: "",
							groups: [],
							friends: []
			end
		end
	end
end