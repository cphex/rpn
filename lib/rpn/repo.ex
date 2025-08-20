defmodule Rpn.Repo do
  use Ecto.Repo,
    otp_app: :rpn,
    adapter: Ecto.Adapters.SQLite3
end
