defmodule Hologram.Test.Fixtures.Mix.Tasks.Holo.Routes.Module4 do
  use Hologram.Page

  route "//cylk.:host/hologram-test-fixtures-mix-tasks-holo-routes-module4"

  layout Hologram.Test.Fixtures.Mix.Tasks.Holo.Routes.Module2

  @impl Page
  def template do
    ~HOLO""
  end
end
