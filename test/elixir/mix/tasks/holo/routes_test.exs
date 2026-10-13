defmodule Mix.Tasks.Holo.RoutesTest do
  # One test sets a host in the application environment every test reads.
  use Hologram.Test.BasicCase, async: false
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

  test "run/1 prefixes each route with the host its page's OTP application configures" do
    Application.put_env(:hologram, :host, "luma.test")
    on_exit(fn -> Application.delete_env(:hologram, :host) end)

    output = capture_io(fn -> Task.run([]) end)

    assert String.contains?(
             output,
             "\nluma.test/hologram-test-fixtures-mix-tasks-holo-routes-module1\n"
           )
  end
end
