defmodule Hologram.UI.LinkTest do
  use Hologram.Test.ComponentCase, async: false

  alias Hologram.Test.Fixtures.UI.Link.Module1
  alias Hologram.Test.Fixtures.UI.Link.Module2
  alias Hologram.Test.Fixtures.UI.Link.Module3
  alias Hologram.Test.Fixtures.UI.Link.Module4
  alias Hologram.Test.Fixtures.UI.Link.Module5
  alias Hologram.Template.Renderer.Env
  alias Hologram.UI.Link

  test "with text anchor, no props" do
    assert render_markup(~HOLO"<Link to={Module1}>my anchor text</Link>") ==
             ~s'<a href="/hologram-test-fixtures-ui-link-module1">my anchor text</a>'
  end

  test "with non-text anchor" do
    assert render_markup(~HOLO"<Link to={Module1}><div>my anchor text</div></Link>") ==
             ~s'<a href="/hologram-test-fixtures-ui-link-module1"><div>my anchor text</div></a>'
  end

  test "with page params" do
    assert render_markup(~HOLO"<Link to={Module2, abc: 123, xyz: 987}>my anchor text</Link>") ==
             ~s'<a href="/hologram-test-fixtures-ui-link-module2/123/987">my anchor text</a>'
  end

  test "with class prop" do
    assert render_markup(~HOLO'<Link to={Module1} class="my_class">my anchor text</Link>') ==
             ~s'<a href="/hologram-test-fixtures-ui-link-module1" class="my_class">my anchor text</a>'
  end

  test "with rel prop" do
    assert render_markup(~HOLO'<Link to={Module1} rel="nofollow">my anchor text</Link>') ==
             ~s'<a href="/hologram-test-fixtures-ui-link-module1" rel="nofollow">my anchor text</a>'
  end

  test "with style prop" do
    assert render_markup(~HOLO'<Link to={Module1} style="my_style">my anchor text</Link>') ==
             ~s'<a href="/hologram-test-fixtures-ui-link-module1" style="my_style">my anchor text</a>'
  end

  test "with special chars in href" do
    markup =
      ~HOLO'<Link to={Module3, a: "hello world", b: "foo/bar"} style="my_style">my anchor text</Link>'

    expected =
      ~s'<a href="/hologram-test-fixtures-ui-link-module3/hello%20world/foo%2Fbar" style="my_style">my anchor text</a>'

    assert render_markup(markup) == expected
  end

  describe "on a subdomain page" do
    setup do
      page_origin = %{scheme: "https", subdomain: "luma", base_host: "localhost", port: 5200}
      [env: %Env{context: %{{Hologram.Runtime, :page_origin} => page_origin}}]
    end

    test "link to a page on the same subdomain", %{env: env} do
      assert render_markup(~HOLO"<Link to={Module4}>my anchor text</Link>", %{}, env) ==
               ~s'<a href="/hologram-test-fixtures-ui-link-module4">my anchor text</a>'
    end

    test "link to a page on another subdomain", %{env: env} do
      assert render_markup(~HOLO"<Link to={Module5}>my anchor text</Link>", %{}, env) ==
               ~s'<a href="https://cylk.localhost:5200/hologram-test-fixtures-ui-link-module5">my anchor text</a>'
    end
  end
end
