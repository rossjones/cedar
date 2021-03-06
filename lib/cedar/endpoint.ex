defmodule Cedar.Endpoint do
  use Phoenix.Endpoint, otp_app: :cedar

 socket "/ws", Cedar.UserSocket

  if code_reloading? do
    plug Phoenix.LiveReloader
    plug Phoenix.CodeReloader
  end

  # Serve at "/" the given assets from "priv/static" directory
  plug Plug.Static,
    at: "/", from: :cedar,
    only: ~w(css images js favicon.ico robots.txt)

  plug Plug.Logger

  # Code reloading will only work if the :code_reloader key of
  # the :phoenix application is set to true in your config file.
  plug Phoenix.CodeReloader

  plug Plug.Parsers,
    parsers: [:urlencoded, :multipart, :json],
    pass: ["*/*"],
    json_decoder: Poison

  plug Plug.MethodOverride
  plug Plug.Head

  plug Plug.Session,
    store: :cookie,
    key: "_cedar_key",
    signing_salt: "XreCosfr",
    encryption_salt: "3I/A4Miw"

  plug Cedar.Router

end
