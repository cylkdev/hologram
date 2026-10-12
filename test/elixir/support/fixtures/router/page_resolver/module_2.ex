defmodule Hologram.Test.Fixtures.Router.PageModuleResolver.Module2 do
  use Hologram.Page

  route "//luma.:host/hologram-test-fixtures-router-pagemoduleresolver-module2"

  layout Hologram.Test.Fixtures.LayoutFixture

  @impl Page
  def template do
    ~HOLO"""
    page Hologram.Test.Fixtures.Router.PageModuleResolver.Module2 template
    """
  end
end
