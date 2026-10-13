defmodule Hologram.Test.Fixtures.Router.PageModuleResolver.Module3 do
  use Hologram.Page

  route "/hologram-test-fixtures-router-pagemoduleresolver-module3"

  layout Hologram.Test.Fixtures.LayoutFixture

  @impl Page
  def template do
    ~HOLO"""
    page Hologram.Test.Fixtures.Router.PageModuleResolver.Module3 template
    """
  end
end
