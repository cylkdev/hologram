defmodule Hologram.Test.Fixtures.Router.Endpoint do
  # Stands in for the Phoenix endpoint a request passes through: Hologram reads
  # only its public url, whose scheme and port links to another host use.
  def struct_url, do: %URI{scheme: "https", host: "localhost", port: 5200}
end
