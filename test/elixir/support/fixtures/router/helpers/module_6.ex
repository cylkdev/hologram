defmodule Hologram.Test.Fixtures.Router.Helpers.Module6 do
  use Hologram.Page

  route "//cylk.:host/hologram-test-fixtures-router-helpers-module6"

  layout Hologram.Test.Fixtures.LayoutFixture

  @impl Page
  def template do
    ~HOLO""
  end
end
