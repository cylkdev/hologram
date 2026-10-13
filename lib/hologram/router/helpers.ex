defmodule Hologram.Router.Helpers do
  alias Hologram.Assets.PathRegistry, as: AssetPathRegistry
  alias Hologram.Reflection

  @doc """
  Retrieves the asset path, including the digest, for the specified static file within the static directory.
  If there's no corresponding entry for the provided static file, the static file path itself will be returned.
  """
  @spec asset_path(String.t()) :: String.t()
  def asset_path(static_path) do
    case AssetPathRegistry.lookup(static_path) do
      {:ok, asset_path} ->
        asset_path

      :error ->
        raise Hologram.AssetNotFoundError, "there is no such asset: \"#{static_path}\""
    end
  end

  @doc """
  Returns the relative URL of a page's JavaScript bundle using the page's digest.
  """
  @spec page_bundle_path(String.t()) :: String.t()
  def page_bundle_path(page_digest) do
    "/hologram/page-#{page_digest}.js"
  end

  @doc """
  Builds relative URL for the given page module or a tuple of a page module and params.
  """
  @spec page_path(module | tuple) :: String.t()

  def page_path({module, params}) do
    page_path(module, params)
  end

  def page_path(module) do
    page_path(module, [])
  end

  @doc """
  Builds relative URL for the given page module and params.
  """
  @spec page_path(module, keyword | map) :: String.t()

  def page_path(page_module, params) when is_map(params) do
    page_path(page_module, Map.to_list(params))
  end

  def page_path(page_module, params) do
    required_params = page_module.__params__()
    initial_acc = {params, page_module.__route__()}

    {remaining_params, path} =
      Enum.reduce(required_params, initial_acc, &process_param(&1, &2, page_module, params))

    ensure_no_extra_params!(remaining_params, page_module)

    path
  end

  @doc """
  Builds the URL a link on a page with the given origin uses for the given page module or tuple
  of a page module and params: the relative URL when the page is served on the origin's host or
  on every host, or the full URL on the page's own host, with the origin's scheme and port, when
  it is served on another host.
  """
  @spec page_url(module | tuple, map | nil) :: String.t()
  def page_url(to, page_origin) do
    path = page_path(to)

    if same_host?(to, page_origin) do
      path
    else
      host = Map.fetch!(page_origin.page_hosts, target_page_module(to))

      "#{page_origin.scheme}://#{host}" <>
        port_suffix(page_origin.scheme, page_origin.port) <> path
    end
  end

  @doc """
  Returns whether a link to the given page module or tuple of a page module and params, on a page
  with the given origin, stays on that page's host: the page is served on the origin's host or on
  every host. With no origin there is no other host to tell apart, so the link stays.
  """
  @spec same_host?(module | tuple, map | nil) :: boolean
  def same_host?(_to, nil), do: true

  def same_host?(to, page_origin) do
    host = Map.fetch!(page_origin.page_hosts, target_page_module(to))
    is_nil(host) or host == page_origin.host
  end

  # The port unless it is the scheme's default.
  defp port_suffix("https", 443), do: ""
  defp port_suffix("http", 80), do: ""
  defp port_suffix(_scheme, port), do: ":#{port}"

  defp target_page_module({page_module, _params}), do: page_module
  defp target_page_module(page_module), do: page_module

  defp encode_param_value(value) do
    value
    |> to_string()
    |> URI.encode(&URI.char_unreserved?/1)
  end

  defp ensure_no_extra_params!([], _page_module), do: :ok

  defp ensure_no_extra_params!(remaining_params, page_module) do
    {key, _value} = hd(remaining_params)

    raise ArgumentError,
          ~s/page "#{Reflection.module_name(page_module)}" doesn't expect "#{key}" param/
  end

  defp ensure_param_exists!(params, key, page_module) do
    if not Keyword.has_key?(params, key) do
      raise ArgumentError,
            ~s'page "#{Reflection.module_name(page_module)}" expects "#{key}" param'
    end
  end

  defp process_param({key, _type, _opts}, {params_acc, path_acc}, page_module, original_params) do
    ensure_param_exists!(params_acc, key, page_module)

    encoded_value = encode_param_value(original_params[key])
    new_path = String.replace(path_acc, ":#{key}", encoded_value)
    new_params = Keyword.drop(params_acc, [key])

    {new_params, new_path}
  end
end
