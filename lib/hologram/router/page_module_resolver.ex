defmodule Hologram.Router.PageModuleResolver do
  @moduledoc false

  use GenServer

  alias Hologram.Reflection
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
  Returns the host each page is served on, keyed by page module: the `:host` the page's OTP
  application configures, or nil when it configures none.
  """
  @spec page_hosts() :: %{module => String.t() | nil}
  def page_hosts do
    %{page_hosts: page_hosts} = :persistent_term.get(impl().persistent_term_key())
    page_hosts
  end

  @doc """
  Given the request's host and its path, returns the page module that handles it, or false when
  no page does.

  A page served on the request's host wins over a page served on every host with the same path.
  """
  @spec resolve(String.t(), String.t()) :: module | false
  def resolve(host, request_path) do
    %{search_trees: search_trees} = :persistent_term.get(impl().persistent_term_key())

    match(search_trees, host, request_path) ||
      match(search_trees, nil, request_path)
  end

  @doc """
  Returns the host each of the given pages is served on: the `:host` its OTP application
  configures, or nil when it configures none.
  """
  @spec build_page_hosts([module]) :: %{module => String.t() | nil}
  def build_page_hosts(page_modules) do
    Map.new(page_modules, fn page_module ->
      otp_app = Application.get_application(page_module)
      {page_module, Application.get_env(otp_app, :host)}
    end)
  end

  @doc """
  Builds one route table per host from the given pages' hosts, plus the table of the pages
  served on every host under nil.
  """
  @spec build_search_trees(%{module => String.t() | nil}) :: %{
          (String.t() | nil) => SearchTree.Node.t()
        }
  def build_search_trees(page_hosts) do
    Enum.reduce(page_hosts, %{nil => %SearchTree.Node{}}, fn {page_module, host}, acc ->
      search_tree = Map.get(acc, host, %SearchTree.Node{})
      Map.put(acc, host, SearchTree.add_route(search_tree, page_module.__route__(), page_module))
    end)
  end

  defp impl do
    Application.get_env(:hologram, :page_module_resolver_impl, __MODULE__)
  end

  defp match(search_trees, host, request_path) do
    case Map.fetch(search_trees, host) do
      {:ok, search_tree} -> SearchTree.match_route(search_tree, request_path)
      :error -> false
    end
  end

  defp populate_persistent_term do
    page_hosts = build_page_hosts(Reflection.list_pages())
    search_trees = build_search_trees(page_hosts)
    persistent_term_key = impl().persistent_term_key()

    :persistent_term.put(persistent_term_key, %{
      page_hosts: page_hosts,
      search_trees: search_trees
    })
  end
end
