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
  alias Hologram.Test.Fixtures.Router.PageModuleResolver.Module4

  use_module_stub :page_module_resolver

  setup :set_mox_global

  setup do
    setup_page_module_resolver(PageModuleResolverStub, false)
  end

  test "init/1" do
    assert init(nil) == {:ok, nil}

    search_tree = :persistent_term.get(PageModuleResolverStub.persistent_term_key())

    assert %{
             nil => %SearchTree.Node{
               value: nil,
               children: %{
                 "hologram-test-fixtures-router-pagemoduleresolver-module1" => %SearchTree.Node{
                   value: Module1,
                   children: %{}
                 }
               }
             },
             "luma" => %SearchTree.Node{
               value: nil,
               children: %{
                 "hologram-test-fixtures-router-pagemoduleresolver-module2" => %SearchTree.Node{
                   value: Module2,
                   children: %{}
                 }
               }
             }
           } = search_tree
  end

  test "reload/0" do
    key = PageModuleResolverStub.persistent_term_key()
    :persistent_term.put(key, :dummy_value)

    reload()

    assert %{
             nil => %SearchTree.Node{
               value: nil,
               children: %{
                 "hologram-test-fixtures-router-pagemoduleresolver-module1" => %SearchTree.Node{
                   value: Module1,
                   children: %{}
                 }
               }
             },
             "luma" => %SearchTree.Node{
               value: nil,
               children: %{
                 "hologram-test-fixtures-router-pagemoduleresolver-module2" => %SearchTree.Node{
                   value: Module2,
                   children: %{}
                 }
               }
             }
           } = :persistent_term.get(key)
  end

  describe "resolve/2" do
    setup do
      init(nil)
      :ok
    end

    test "there is a matching route" do
      request_path = "/hologram-test-fixtures-router-pagemoduleresolver-module1"
      assert resolve(nil, request_path) == Module1
    end

    test "there is no matching route" do
      request_path = "/unknown-path"
      refute resolve(nil, request_path)
    end

    test "subdomain route on its subdomain" do
      request_path = "/hologram-test-fixtures-router-pagemoduleresolver-module2"
      assert resolve("luma", request_path) == Module2
    end

    test "subdomain route without a subdomain" do
      request_path = "/hologram-test-fixtures-router-pagemoduleresolver-module2"
      refute resolve(nil, request_path)
    end

    test "subdomain route on another subdomain" do
      request_path = "/hologram-test-fixtures-router-pagemoduleresolver-module2"
      refute resolve("cylk", request_path)
    end

    test "subdomain route wins over a plain route with the same path" do
      request_path = "/hologram-test-fixtures-router-pagemoduleresolver-shared"
      assert resolve("luma", request_path) == Module3
    end

    test "plain route without a subdomain where a subdomain route shares its path" do
      request_path = "/hologram-test-fixtures-router-pagemoduleresolver-shared"
      assert resolve(nil, request_path) == Module4
    end

    test "plain route on a subdomain" do
      request_path = "/hologram-test-fixtures-router-pagemoduleresolver-module1"
      assert resolve("luma", request_path) == Module1
    end
  end

  test "start_link/1" do
    assert {:ok, pid} = PageModuleResolver.start_link([])
    assert is_pid(pid)
    assert persistent_term_exists?(PageModuleResolverStub.persistent_term_key())
  end
end
