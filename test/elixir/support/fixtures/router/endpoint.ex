defmodule Hologram.Test.Fixtures.Router.Endpoint do
  # Stands in for the Phoenix endpoint a request passes through: the router
  # reads only its url host, the base domain subdomain routes hang off.
  def config(:url), do: [host: "localhost"]
end
