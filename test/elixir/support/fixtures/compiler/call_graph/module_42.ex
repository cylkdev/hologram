# credo:disable-for-this-file Credo.Check.Readability.Specs
defmodule Hologram.Test.Fixtures.Compiler.CallGraph.Module42 do
  alias Hologram.Test.Fixtures.Compiler.CallGraph.Module43

  def my_fun_42 do
    Module43.my_fun_43b()
  end
end
