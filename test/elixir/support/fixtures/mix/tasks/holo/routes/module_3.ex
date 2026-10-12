defmodule Hologram.Test.Fixtures.Mix.Tasks.Holo.Routes.Module3 do
  use Hologram.Page

  route "//luma.:host/hologram-test-fixtures-mix-tasks-holo-routes-module3"

  layout Hologram.Test.Fixtures.Mix.Tasks.Holo.Routes.Module2

  @impl Page
  def template do
    ~HOLO""
  end
end
