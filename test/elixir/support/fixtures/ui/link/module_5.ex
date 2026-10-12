defmodule Hologram.Test.Fixtures.UI.Link.Module5 do
  use Hologram.Page

  route "//cylk.:host/hologram-test-fixtures-ui-link-module5"

  layout Hologram.Test.Fixtures.LayoutFixture

  @impl Page
  def template do
    ~HOLO""
  end
end
