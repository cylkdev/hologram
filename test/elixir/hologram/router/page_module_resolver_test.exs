defmodule Hologram.Router.PageModuleResolverTest do
  use Hologram.Test.BasicCase, async: false

  import Hologram.Router.PageModuleResolver
  import Hologram.Test.Stubs
  import Mox

  alias Hologram.Router.PageModuleResolver
  alias Hologram.Router.SearchTree
  alias Hologram.Test.Fixtures.Router.PageModuleResolver.Module1
  alias Hologram.Test.Fixtures.Router.PageModuleResolver.Module2
  alias Hologram.Test.Fixtures.Router.PageModuleResolver.Module3

  use_module_stub :page_module_resolver

  # Shares Module3's path. It is defined here rather than as a fixture so the route table built
  # from every page of the app never holds both.
  defmodule SharedPathPage do
    use Hologram.Page

    route "/hologram-test-fixtures-router-pagemoduleresolver-module3"

    layout Hologram.Test.Fixtures.LayoutFixture

    @impl Page
    def template do
      ~HOLO""
    end
  end

  setup :set_mox_global

  setup do
    setup_page_module_resolver(PageModuleResolverStub, false)
  end

  test "init/1" do
    assert init(nil) == {:ok, nil}

    %{page_hosts: page_hosts, search_trees: search_trees} =
      :persistent_term.get(PageModuleResolverStub.persistent_term_key())

    assert page_hosts[Module1] == nil

    assert %{
             nil => %SearchTree.Node{
               value: nil,
               children: %{
                 "hologram-test-fixtures-router-pagemoduleresolver-module1" => %SearchTree.Node{
                   value: Module1,
                   children: %{}
                 }
               }
             }
           } = search_trees
  end

  test "reload/0" do
    key = PageModuleResolverStub.persistent_term_key()
    :persistent_term.put(key, :dummy_value)

    reload()

    assert %{
             search_trees: %{
               nil => %SearchTree.Node{
                 value: nil,
                 children: %{
                   "hologram-test-fixtures-router-pagemoduleresolver-module1" => %SearchTree.Node{
                     value: Module1,
                     children: %{}
                   }
                 }
               }
             }
           } = :persistent_term.get(key)
  end

  describe "build_page_hosts/1" do
    test "a page whose OTP application configures no host is served on every host" do
      assert build_page_hosts([Module1]) == %{Module1 => nil}
    end

    test "a page is served on the host its OTP application configures" do
      Application.put_env(:hologram, :host, "luma.test")
      on_exit(fn -> Application.delete_env(:hologram, :host) end)

      assert build_page_hosts([Module1]) == %{Module1 => "luma.test"}
    end
  end

  test "build_search_trees/1" do
    assert build_search_trees(%{Module1 => nil, Module2 => "luma.test"}) == %{
             nil => %SearchTree.Node{
               value: nil,
               children: %{
                 "hologram-test-fixtures-router-pagemoduleresolver-module1" => %SearchTree.Node{
                   value: Module1,
                   children: %{}
                 }
               }
             },
             "luma.test" => %SearchTree.Node{
               value: nil,
               children: %{
                 "hologram-test-fixtures-router-pagemoduleresolver-module2" => %SearchTree.Node{
                   value: Module2,
                   children: %{}
                 }
               }
             }
           }
  end

  test "page_hosts/0" do
    page_hosts = %{Module1 => nil, Module2 => "luma.test"}

    :persistent_term.put(PageModuleResolverStub.persistent_term_key(), %{
      page_hosts: page_hosts,
      search_trees: build_search_trees(page_hosts)
    })

    assert page_hosts() == page_hosts
  end

  describe "resolve/2" do
    setup do
      page_hosts = %{
        Module1 => nil,
        Module2 => "luma.test",
        Module3 => "luma.test",
        SharedPathPage => nil
      }

      :persistent_term.put(PageModuleResolverStub.persistent_term_key(), %{
        page_hosts: page_hosts,
        search_trees: build_search_trees(page_hosts)
      })

      :ok
    end

    test "there is a matching route" do
      request_path = "/hologram-test-fixtures-router-pagemoduleresolver-module1"
      assert resolve("cylk.test", request_path) == Module1
    end

    test "there is no matching route" do
      request_path = "/unknown-path"
      refute resolve("cylk.test", request_path)
    end

    test "a page on its host" do
      request_path = "/hologram-test-fixtures-router-pagemoduleresolver-module2"
      assert resolve("luma.test", request_path) == Module2
    end

    test "a page on another host" do
      request_path = "/hologram-test-fixtures-router-pagemoduleresolver-module2"
      refute resolve("cylk.test", request_path)
    end

    test "a page on its host wins over a page on every host with the same path" do
      request_path = "/hologram-test-fixtures-router-pagemoduleresolver-module3"
      assert resolve("luma.test", request_path) == Module3
    end

    test "a page on every host on another host where a host's page shares its path" do
      request_path = "/hologram-test-fixtures-router-pagemoduleresolver-module3"
      assert resolve("cylk.test", request_path) == SharedPathPage
    end
  end

  test "start_link/1" do
    assert {:ok, pid} = PageModuleResolver.start_link([])
    assert is_pid(pid)
    assert persistent_term_exists?(PageModuleResolverStub.persistent_term_key())
  end
end
