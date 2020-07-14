# defmodule Mockapp.Request.Manager do
#   @moduledoc false

#   use GenServer
#   require Logger

#   @schedulers_online System.schedulers_online() * 5

#   def start_link(opts), do: GenServer.start_link(__MODULE__, opts, name: __MODULE__)
#   def init(opts), do: {:ok, opts}

#   def handle_cast({:multi_delete, mocks}, state) do
#     stream =
#       Task.Supervisor.async_stream_nolink(
#         RequestMock.Task.Supervisor,
#         mocks,
#         fn mock ->
#           delete(mock)
#         end,
#         max_concurrency: @schedulers_online
#       )

#     Stream.run(stream)
#     {:noreply, state}
#   end

#   def create(uuid, conn) do
#     Logger.info("Creating request for #{uuid}...")

#     Task.Supervisor.async(RequestMock.Task.Supervisor, fn ->
#       name = :os.system_time(:milli_seconds)
#       path = absolute_file_path(uuid)

#       persist(name, path, conn)
#     end)
#   end

#   def delete(uuid) do
#     task =
#       Task.Supervisor.async_nolink(RequestMock.Task.Supervisor, fn ->
#         with path <- absolute_file_path(uuid),
#              {:ok, _} <- File.rm_rf(path) do
#           :ok
#         else
#           _ -> :error
#         end
#       end)

#     Task.await(task)
#   end

#   def persist(name, path, %Plug.Conn{} = conn) do
#     with :ok <- File.mkdir_p(path),
#          absolute_path <- Enum.join([path, name], "/"),
#          :ok <- File.touch(absolute_path) do
#       File.open(absolute_path, [:write], fn file ->
#         # Logger.info "[#{absolute_path}] Writing datetime  ..."
#         IO.write(file, datetime_now() <> "\n")

#         # Logger.info "[#{absolute_path}] Writing ip  ..."
#         IO.write(file, Enum.join(Tuple.to_list(conn.remote_ip), ".") <> "\n")

#         # Logger.info "[#{absolute_path}] Writing http_method  ..."
#         IO.write(file, conn.method <> "\n")

#         # Logger.info "[#{absolute_path}] Writing content_type  ..."
#         IO.write(file, Enum.join(Plug.Conn.get_req_header(conn, "content-type"), " ") <> "\n")

#         # Logger.info "[#{absolute_path}] Writing user_agent  ..."
#         IO.write(file, Enum.join(Plug.Conn.get_req_header(conn, "user-agent"), " ") <> "\n")

#         # Logger.info "[#{absolute_path}] Writing request_path  ..."
#         IO.write(file, conn.request_path <> "\n")

#         # Logger.info "[#{absolute_path}] Writing body_params  ..."
#         body_params =
#           Enum.map(Map.to_list(conn.body_params), fn {key, value} ->
#             if String.valid?(key) && String.valid?(value) do
#               key <> "=" <> value
#             end
#           end)

#         IO.write(
#           file,
#           :iconv.convert("utf-8", "ascii//translit", Enum.join(body_params, "&") <> "\n")
#         )

#         # Logger.info "[#{absolute_path}] Writing query_string  ..."
#         IO.write(file, conn.query_string <> "\n")
#       end)

#       Logger.info("#{absolute_path} generated...")
#     else
#       _ ->
#         Logger.info("Can't persist request " <> Enum.join([path, name], "/") <> " ...")
#     end
#   end

#   def get(uuid, limit \\ 30) do
#     path = absolute_file_path(uuid)

#     cmd = "ls #{path} | sort -r | head -n #{limit}"

#     requests =
#       cmd
#       |> String.to_charlist()
#       |> :os.cmd()
#       |> to_string
#       |> String.split("\n")
#       |> Enum.drop(-1)

#     requests =
#       Enum.map(requests, fn request ->
#         case read(path, request) do
#           {:ok, value} -> value
#           {:error, _} -> nil
#         end
#       end)

#     Enum.filter(requests, &RequestMock.Request.Entity.is_struct?(&1))
#   end

#   def read(path, request) do
#     path = Enum.join([path, request], "/")

#     File.open(path, [:read], fn file ->
#       request = struct(Mockapp.Request.Entity)

#       datetime = parse_file(file, :line, datetime_now(), &String.trim(&1))
#       ip = parse_file(file, :line, "0.0.0.0", &String.trim(&1))
#       method = parse_file(file, :line, "", &String.trim(&1))
#       content_type = parse_file(file, :line, "", &String.trim(&1))
#       user_agent = parse_file(file, :line, "", &String.trim(&1))
#       path = parse_file(file, :line, "", &String.trim(&1))
#       body_params = parse_file(file, :line, "", &String.trim(&1))
#       query_string = parse_file(file, :line, "", &String.trim(&1))

#       %{
#         request
#         | datetime: datetime,
#           ip: ip,
#           method: method,
#           body_params: body_params,
#           query_string: query_string,
#           content_type: content_type,
#           user_agent: user_agent,
#           path: path
#       }
#     end)
#   end

#   defp parse_file(file, line_or_chars, default, func)
#        when line_or_chars in [:line, :all] and is_function(func) do
#     case IO.read(file, line_or_chars) do
#       :eof -> default
#       value -> func.(value)
#     end
#   end

#   defp datetime_now do
#     :erlang.localtime()
#     |> NaiveDateTime.from_erl!()
#     |> NaiveDateTime.to_string()
#   end

#   defp absolute_file_path(file_name) do
#     mocks_dir =
#       :mockapp
#       |> Application.get_env(:requests)
#       |> Keyword.fetch!(:anonymous)

#     Enum.join([mocks_dir, file_name], "/")
#   end
# end
