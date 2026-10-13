defmodule Hologram.Test.Fixtures.Router.Helpers.Module4 do
  use Hologram.Page

  route "/hologram-test-fixtures-router-helpers-module4"

  layout Hologram.Test.Fixtures.LayoutFixture

  @impl Page
  def template do
    ~HOLO""
  end
end
