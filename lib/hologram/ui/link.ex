defmodule Hologram.UI.Link do
  use Hologram.Component

  alias Hologram.Router.Helpers, as: RouterHelpers

  prop :class, :string, default: nil
  prop :page_origin, :map, default: nil, from_context: {Hologram.Runtime, :page_origin}
  prop :rel, :string, default: nil
  prop :style, :string, default: nil
  prop :to, [:module, :string, :tuple]

  # A link to a page on another host is a plain anchor: the browser loads that page, since
  # navigation inside the app cannot move it to another host.
  @impl Component
  def template do
    ~HOLO"""
    {%if RouterHelpers.same_host?(@to, @page_origin)}<a
      href={page_path(@to)}
      class={@class}
      rel={@rel}
      style={@style}
      $pointerdown={:__prefetch_page__, to: @to}
      $click.prevent_default={:__load_prefetched_page__, to: @to}
    ><slot /></a>{%else}<a href={RouterHelpers.page_url(@to, @page_origin)} class={@class} rel={@rel} style={@style}><slot /></a>{/if}
    """
  end
end
