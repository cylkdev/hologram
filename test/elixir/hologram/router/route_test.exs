defmodule Hologram.Router.RouteTest do
  use Hologram.Test.BasicCase, async: true
  import Hologram.Router.Route

  describe "split/1" do
    test "subdomain route" do
      assert split("//luma.:host/login") == {"luma", "/login"}
    end

    test "subdomain route at the subdomain's root" do
      assert split("//luma.:host") == {"luma", "/"}
    end

    test "subdomain route with params" do
      assert split("//luma.:host/conversations/:id") == {"luma", "/conversations/:id"}
    end

    test "plain route" do
      assert split("/login") == {nil, "/login"}
    end

    test "host part without .:host" do
      assert_raise ArgumentError,
                   ~s/route "\/\/luma\/login" must name its host as "\/\/<subdomain>.:host\/..."/,
                   fn -> split("//luma/login") end
    end

    test "host part without a subdomain" do
      assert_raise ArgumentError,
                   ~s/route "\/\/:host\/login" must name its host as "\/\/<subdomain>.:host\/..."/,
                   fn -> split("//:host/login") end
    end
  end

  describe "subdomain/2" do
    test "one label on the base domain" do
      assert subdomain("luma.example.com", "example.com") == "luma"
    end

    test "one label on localhost" do
      assert subdomain("luma.localhost", "localhost") == "luma"
    end

    test "the base domain itself" do
      assert subdomain("example.com", "example.com") == nil
    end

    test "more than one label on the base domain" do
      assert subdomain("app.luma.example.com", "example.com") == nil
    end

    test "a host not on the base domain" do
      assert subdomain("luma.other.com", "example.com") == nil
    end
  end
end
