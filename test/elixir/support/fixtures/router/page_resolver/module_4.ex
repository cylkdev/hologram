defmodule Hologram.Test.Fixtures.Router.PageModuleResolver.Module4 do
  use Hologram.Page

  route "/hologram-test-fixtures-router-pagemoduleresolver-shared"

  layout Hologram.Test.Fixtures.LayoutFixture

  @impl Page
  def template do
    ~HOLO"""
    page Hologram.Test.Fixtures.Router.PageModuleResolver.Module4 template
    """
  end
end
