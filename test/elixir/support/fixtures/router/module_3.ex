defmodule Hologram.Test.Fixtures.Router.Module3 do
  use Hologram.Page

  route "//luma.:host/hologram-test-fixtures-router-module3/:a"

  param :a, :integer

  layout Hologram.Test.Fixtures.LayoutWithRuntime

  @impl Page
  def template do
    ~HOLO"Module3 page, a = {inspect(@a)}"
  end
end
