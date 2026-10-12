defmodule Hologram.Test.Fixtures.UI.Link.Module4 do
  use Hologram.Page

  route "//luma.:host/hologram-test-fixtures-ui-link-module4"

  layout Hologram.Test.Fixtures.LayoutFixture

  @impl Page
  def template do
    ~HOLO""
  end
end
