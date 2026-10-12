defmodule Hologram.Router.Route do
  @moduledoc false

  @doc """
  Splits a page's route into the subdomain it is served on and its URL path.

  A route written as "//<subdomain>.:host/<path>" is served only on that
  subdomain of the base domain; a plain route ("/<path>") has no subdomain.
  """
  @spec split(String.t()) :: {String.t() | nil, String.t()}
  def split("//" <> rest = route) do
    [authority | segments] = String.split(rest, "/")

    case String.split(authority, ".") do
      [subdomain, ":host"] when subdomain != "" ->
        {subdomain, "/" <> Enum.join(segments, "/")}

      _other ->
        raise ArgumentError,
              ~s/route "#{route}" must name its host as "\/\/<subdomain>.:host\/..."/
    end
  end

  def split(path), do: {nil, path}

  @doc """
  Returns the subdomain a request's host is on: its one label in front of the base domain, or
  nil for the base domain itself, a host with more than one label in front of it, or a host not
  on the base domain.
  """
  @spec subdomain(String.t(), String.t()) :: String.t() | nil
  def subdomain(host, base_host) do
    case String.split(host, ".", parts: 2) do
      [label, ^base_host] when label != "" -> label
      _other -> nil
    end
  end
end
