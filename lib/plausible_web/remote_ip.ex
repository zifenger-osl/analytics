defmodule PlausibleWeb.RemoteIp do
  def get(conn) do
    cf_connecting_ip = List.first(Plug.Conn.get_req_header(conn, "cf-connecting-ip"))
    forwarded_for = List.first(Plug.Conn.get_req_header(conn, "x-forwarded-for"))

    ip =
      cond do
        cf_connecting_ip ->
          cf_connecting_ip

        forwarded_for ->
          String.split(forwarded_for, ",")
          |> Enum.map(&String.trim/1)
          |> List.first()

        true ->
          to_string(:inet_parse.ntoa(conn.remote_ip))
      end

    truncated(ip)
  end

  defp truncated(ip) do
    case :inet_parse.address(String.to_charlist(ip)) do
      {:ok, {b1, b2, b3, _b4}} ->
        :inet_parse.ntoa({b1, b2, b3, 0}) |> to_string

      {:ok, {b1, b2, b3, b4, b5, b6, b7, _b8}} ->
        :inet_parse.ntoa({b1, b2, b3, b4, b5, b6, b7, 0}) |> to_string

      {:error, _} ->
        nil
    end
  end
end
