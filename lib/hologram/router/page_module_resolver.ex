defmodule Hologram.Router.PageModuleResolver do
  @moduledoc false

  use GenServer

  alias Hologram.Reflection
  alias Hologram.Router.Route
  alias Hologram.Router.SearchTree

  @doc """
  Returns the key of the persistent term used by the page module resolver registered process.
  """
  @callback persistent_term_key() :: any

  @doc """
  Starts page module resolver process.
  """
  @spec start_link(keyword) :: GenServer.on_start()
  def start_link([]) do
    GenServer.start_link(__MODULE__, nil)
  end

  @impl GenServer
  def init(nil) do
    populate_persistent_term()
    {:ok, nil}
  end

  @doc """
  Returns the implementation of the page module resolver's persistent term key.
  """
  @spec persistent_term_key() :: any
  def persistent_term_key do
    __MODULE__
  end

  @doc """
  Reloads the persistent term that stores the search tree used for page module resolving.
  """
  @spec reload :: :ok
  def reload do
    populate_persistent_term()
  end

  @doc """
  Given the request's subdomain (nil when it has none) and its path, returns the page module
  that handles it, or false when no page does.

  A page whose route names the subdomain wins over a plain route with the same path; a plain
  route is served on every host.
  """
  @spec resolve(String.t() | nil, String.t()) :: module | false
  def resolve(subdomain, request_path) do
    search_trees = :persistent_term.get(impl().persistent_term_key())

    match(search_trees, subdomain, request_path) ||
      match(search_trees, nil, request_path)
  end

  # One route table per subdomain, plus the plain routes' table under nil.
  defp build_search_trees do
    Enum.reduce(Reflection.list_pages(), %{nil => %SearchTree.Node{}}, fn page_module, acc ->
      {subdomain, path} = Route.split(page_module.__route__())
      search_tree = Map.get(acc, subdomain, %SearchTree.Node{})
      Map.put(acc, subdomain, SearchTree.add_route(search_tree, path, page_module))
    end)
  end

  defp impl do
    Application.get_env(:hologram, :page_module_resolver_impl, __MODULE__)
  end

  defp match(search_trees, subdomain, request_path) do
    case Map.fetch(search_trees, subdomain) do
      {:ok, search_tree} -> SearchTree.match_route(search_tree, request_path)
      :error -> false
    end
  end

  defp populate_persistent_term do
    search_trees = build_search_trees()
    persistent_term_key = impl().persistent_term_key()

    :persistent_term.put(persistent_term_key, search_trees)
  end
end
