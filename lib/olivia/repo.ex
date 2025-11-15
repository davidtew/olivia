defmodule Olivia.Repo do
  use Ecto.Repo,
    otp_app: :olivia,
    adapter: Ecto.Adapters.Postgres
end
