defmodule Mix.Tasks.Holo.Routes do
  @moduledoc """
  Prints the list of page routes: the routes served on every host first, then each host's routes
  together, prefixed with that host, each group ordered by route path.
  """

  use Mix.Task
  alias Hologram.Reflection
  alias Hologram.Router.PageModuleResolver

  @requirements ["app.config"]

  @doc false
  @impl Mix.Task
  def run(_args) do
    print_header()
    print_routes()

    :ok
  end

  defp print(output) do
    # credo:disable-for-next-line Credo.Check.Refactor.IoPuts
    IO.puts(output)
  end

  defp print_divider do
    "-"
    |> String.duplicate(80)
    |> print()
  end

  defp print_header do
    print_divider()
    print("ROUTE / MODULE / SOURCE FILE")
    print_divider()
  end

  defp print_route({host, route, module}) do
    print("#{host}#{route}")
    print(Reflection.module_name(module))
    print(Reflection.source_path(module))
    print_divider()
  end

  defp print_routes do
    Reflection.list_pages()
    |> PageModuleResolver.build_page_hosts()
    |> Enum.map(fn {module, host} -> {host, module.__route__(), module} end)
    |> Enum.sort_by(fn {host, route, _module} -> {host, route} end)
    |> Enum.each(&print_route/1)
  end
end
