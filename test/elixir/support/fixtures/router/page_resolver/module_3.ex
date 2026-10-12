defmodule Hologram.Test.Fixtures.Router.PageModuleResolver.Module3 do
  use Hologram.Page

  route "//luma.:host/hologram-test-fixtures-router-pagemoduleresolver-shared"

  layout Hologram.Test.Fixtures.LayoutFixture

  @impl Page
  def template do
    ~HOLO"""
    page Hologram.Test.Fixtures.Router.PageModuleResolver.Module3 template
    """
  end
end
