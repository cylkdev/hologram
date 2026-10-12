defmodule Hologram.Test.Fixtures.Controller.Module33 do
  use Hologram.Page

  route "//luma.:host/hologram-test-fixtures-runtime-controller-module33/:aaa/ccc/:bbb"

  param :aaa, :integer
  param :bbb, :integer

  layout Hologram.Test.Fixtures.LayoutFixture

  @impl Page
  def template do
    ~HOLO"""
    param_aaa = {inspect(@aaa)}, param_bbb = {inspect(@bbb)}
    """
  end
end
