defmodule BugReproWeb.ReproLive do
  use BugReproWeb, :live_view

  def mount(_params, _session, socket) do
    socket =
      socket
      |> assign(:items, [
        %{id: 1, name: "Item 1", pinned: false},
        %{id: 2, name: "Item 2", pinned: false},
        %{id: 3, name: "Item 3", pinned: false}
      ])

    {:ok, socket}
  end

  def render(assigns) do
    ~H"""
    <div class="p-8">
      <h1 class="text-2xl font-bold mb-4">Prima Dropdown Bug Reproduction</h1>

      <ul class="space-y-4">
        <%= for item <- @items do %>
          <li
            id={"item-card-#{item.id}"}
            class="border p-4 rounded flex items-center justify-between"
          >
            <div>
              <h3 class="font-semibold">{item.name}</h3>
              <p class="text-sm text-gray-600">
                {if item.pinned, do: "✓ Pinned", else: "Not pinned"}
              </p>
            </div>

            <.thing id={"item-" <> to_string(item.id)}>
              <button
                phx-click="toggle-pin"
                phx-value-id={item.id}
              >
                {if item.pinned, do: "Unpin", else: "Pin"}
              </button>
            </.thing>

          </li>
        <% end %>
      </ul>
    </div>
    """
  end

  def handle_event("toggle-pin", %{"id" => id}, socket) do
    item_id = String.to_integer(id)

    items =
      socket.assigns.items
      |> Enum.map(fn item ->
        if item.id == item_id do
          %{item | pinned: !item.pinned}
        else
          item
        end
      end)
      # Re-sort: pinned items first
      |> Enum.sort_by(& &1.pinned, :desc)

    {:noreply, assign(socket, :items, items)}
  end

  attr :id, :string, required: true
  slot :inner_block, required: true

  def thing(assigns) do
    ~H"""
    <div id={@id} phx-hook=".Thing">
      <.custom_button data-thing>{render_slot(@inner_block)}</.custom_button>
    </div>
    <script :type={Phoenix.LiveView.ColocatedHook} name=".Thing">
      export default {
        mounted() {
          const thingId = this.el.id + 'set-by-hook'
          this.el.querySelector('[data-thing]').id = thingId
        }
      }
    </script>
    """
  end


  attr :rest, :global
  slot :inner_block, required: true

  defp custom_button(assigns) do
    ~H"""
    <button type="button" {@rest}>
      {render_slot(@inner_block)}
    </button>
    """
  end
end
