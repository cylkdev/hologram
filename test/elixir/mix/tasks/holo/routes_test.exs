defmodule Mix.Tasks.Holo.RoutesTest do
  use Hologram.Test.BasicCase, async: true
  import ExUnit.CaptureIO
  alias Mix.Tasks.Holo.Routes, as: Task

  test "run/1" do
    expected_header_output =
      normalize_newlines("""
      --------------------------------------------------------------------------------
      ROUTE / MODULE / SOURCE FILE
      --------------------------------------------------------------------------------\
      """)

    expected_page_module_file_path =
      Path.join([@fixtures_dir, "mix", "tasks", "holo", "routes", "module_1.ex"])

    expected_route_output =
      normalize_newlines("""
      --------------------------------------------------------------------------------
      /hologram-test-fixtures-mix-tasks-holo-routes-module1
      Hologram.Test.Fixtures.Mix.Tasks.Holo.Routes.Module1
      #{expected_page_module_file_path}
      --------------------------------------------------------------------------------\
      """)

    output = capture_io(fn -> Task.run([]) end)

    assert String.contains?(output, expected_header_output)
    assert String.contains?(output, expected_route_output)
  end

  test "run/1 prints subdomain routes as written, after the plain routes, grouped by subdomain" do
    output = capture_io(fn -> Task.run([]) end)

    plain_route = "\n/hologram-test-fixtures-mix-tasks-holo-routes-module1\n"
    cylk_route = "\n//cylk.:host/hologram-test-fixtures-mix-tasks-holo-routes-module4\n"
    luma_route = "\n//luma.:host/hologram-test-fixtures-mix-tasks-holo-routes-module3\n"

    {plain_position, _length} = :binary.match(output, plain_route)
    {cylk_position, _length} = :binary.match(output, cylk_route)
    {luma_position, _length} = :binary.match(output, luma_route)

    assert plain_position < cylk_position
    assert cylk_position < luma_position
  end
end
