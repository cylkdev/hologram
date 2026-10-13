defmodule Hologram.Test.Fixtures.Router.Helpers.Module5 do
  use Hologram.Page

  route "/hologram-test-fixtures-router-helpers-module5/:param_1/:param_2"

  param :param_1, :atom
  param :param_2, :integer

  layout Hologram.Test.Fixtures.LayoutFixture

  @impl Page
  def template do
    ~HOLO""
  end
end
