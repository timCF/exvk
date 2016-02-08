defmodule Exvk.Photos do
	use Silverb
	use Exvk.HTTP
	def get(%{gid: gid, aid: aid}, token, proxy \\ nil) do
		Exvk.timeout
		case %{gid: gid, aid: aid, access_token: token, rev: 1} |> http_get("photos.get", get_opts(proxy)) do
			%{response: response} when is_list(response) -> response
			error -> {:error, error}
		end
	end
	def delete(%{gid: gid, pid: pid}, token, proxy \\ nil) do
		Exvk.timeout
		case %{oid: -1 * abs(gid), pid: pid, access_token: token} |> http_get("photos.delete", get_opts(proxy)) do
			%{response: 1} -> :ok
			error -> {:error, error}
		end
	end
	def upload(%{gid: gid, aid: aid, path: path, caption: caption}, token, proxy \\ nil) do
		Exvk.timeout
		case %{gid: gid, aid: aid, access_token: token} |> http_get("photos.getUploadServer", get_opts(proxy)) do
			%{response: %{upload_url: upload_url}} when is_binary(upload_url) ->
				Exvk.timeout
				case {:multipart, [{:file, path}]} |> http_post( [], get_opts(proxy) |> Map.merge(%{host: upload_url, headers: [{"Content-Type","multipart/form-data"}], encode: :none, decode: :json}) ) do
					%{server: server, aid: aid, gid: gid, hash: hash, photos_list: photos_list} ->
						Exvk.timeout
						case %{server: server, aid: aid, gid: gid, hash: hash, photos_list: photos_list, access_token: token, caption: caption} |> http_get("photos.save") do
							%{response: [_|_]} -> :ok
							error -> {:error, error}
						end
					error ->
						{:error, error}
				end
			error ->
				{:error, error}
		end
	end
end
