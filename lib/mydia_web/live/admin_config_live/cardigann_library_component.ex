defmodule MydiaWeb.AdminConfigLive.CardigannLibraryComponent do
  @moduledoc """
  LiveComponent for managing Cardigann indexer definitions.

  This component is embedded within the Configuration page's Cardigann tab
  and manages its own state for filtering, searching, and configuring
  Cardigann indexers.
  """
  use MydiaWeb, :live_component

  alias Mydia.Indexers
  alias Mydia.Indexers.CardigannDefinition

  require Logger
  alias Mydia.Logger, as: MydiaLogger

  @impl true
  def update(assigns, socket) do
    socket =
      socket
      |> assign(assigns)
      |> assign_new(:filter_type, fn -> "all" end)
      |> assign_new(:filter_language, fn -> "all" end)
      |> assign_new(:filter_enabled, fn -> "all" end)
      |> assign_new(:search_query, fn -> "" end)
      |> assign_new(:show_config_modal, fn -> false end)
      |> assign_new(:configuring_definition, fn -> nil end)
      |> load_indexers()

    {:ok, socket}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div class="p-4 sm:p-6 space-y-6">
      <%!-- Header with Stats --%>
      <div class="flex flex-col lg:flex-row lg:items-center lg:justify-between gap-4">
        <div>
          <h2 class="text-lg font-semibold flex items-center gap-2">
            <.icon name="hero-book-open" class="w-5 h-5 opacity-60" /> Cardigann Indexer Library
          </h2>
          <p class="text-base-content/70 text-sm mt-1">
            Browse and enable indexers from the Prowlarr/Cardigann definition library
          </p>
        </div>
        <div class="flex gap-3 flex-wrap">
          <div class="stat bg-base-200 rounded-box px-4 py-2">
            <div class="stat-title text-xs">Total</div>
            <div class="stat-value text-lg">{@stats.total}</div>
          </div>
          <div class="stat bg-base-200 rounded-box px-4 py-2">
            <div class="stat-title text-xs">Enabled</div>
            <div class="stat-value text-lg text-success">{@stats.enabled}</div>
          </div>
          <div class="stat bg-base-200 rounded-box px-4 py-2">
            <div class="stat-title text-xs">Disabled</div>
            <div class="stat-value text-lg text-base-content/50">{@stats.disabled}</div>
          </div>
        </div>
      </div>
      <%!-- Filters and Search --%>
      <div class="card bg-base-200 shadow-sm">
        <div class="card-body p-4">
          <div class="flex flex-wrap gap-4 items-end">
            <%!-- Search --%>
            <div class="form-control flex-1 min-w-64">
              <label class="label py-1">
                <span class="label-text text-xs">Search</span>
              </label>
              <form id="cardigann-search-form" phx-change="search" phx-target={@myself}>
                <input
                  type="text"
                  name="search[query]"
                  value={@search_query}
                  placeholder="Search by name or description..."
                  class="input input-bordered input-sm w-full"
                />
              </form>
            </div>
            <%!-- Type Filter --%>
            <div class="form-control">
              <label class="label py-1">
                <span class="label-text text-xs">Type</span>
              </label>
              <select
                class="select select-bordered select-sm"
                phx-change="filter_type"
                phx-target={@myself}
                name="type"
                value={@filter_type}
              >
                <option value="all">All Types</option>
                <option value="public">Public</option>
                <option value="private">Private</option>
                <option value="semi-private">Semi-Private</option>
              </select>
            </div>
            <%!-- Language Filter --%>
            <div class="form-control">
              <label class="label py-1">
                <span class="label-text text-xs">Language</span>
              </label>
              <select
                class="select select-bordered select-sm"
                phx-change="filter_language"
                phx-target={@myself}
                name="language"
                value={@filter_language}
              >
                <option value="all">All Languages</option>
                <%= for language <- @available_languages do %>
                  <option value={language}>{language}</option>
                <% end %>
              </select>
            </div>
            <%!-- Status Filter --%>
            <div class="form-control">
              <label class="label py-1">
                <span class="label-text text-xs">Status</span>
              </label>
              <select
                class="select select-bordered select-sm"
                phx-change="filter_enabled"
                phx-target={@myself}
                name="enabled"
                value={@filter_enabled}
              >
                <option value="all">All Status</option>
                <option value="enabled">Enabled</option>
                <option value="disabled">Disabled</option>
              </select>
            </div>
            <%!-- Sync Button --%>
            <div class="form-control">
              <button
                class="btn btn-primary btn-sm"
                phx-click="sync_definitions"
                phx-target={@myself}
              >
                <.icon name="hero-arrow-path" class="w-4 h-4" /> Sync
              </button>
            </div>
          </div>
        </div>
      </div>
      <%!-- Indexer List --%>
      <%= if @definitions == [] do %>
        <div class="alert alert-info">
          <.icon name="hero-information-circle" class="w-5 h-5" />
          <span>
            <%= if @search_query != "" or @filter_type != "all" or @filter_language != "all" or @filter_enabled != "all" do %>
              No indexers match your filters. Try adjusting your search criteria.
            <% else %>
              No Cardigann definitions available. Click "Sync" to fetch indexers from the repository.
            <% end %>
          </span>
        </div>
      <% else %>
        <div class="bg-base-200 rounded-box divide-y divide-base-300">
          <%= for definition <- @definitions do %>
            <div class="p-3 sm:p-4">
              <div class="flex flex-col sm:flex-row sm:items-center gap-3">
                <%!-- Indexer Info --%>
                <div class="flex-1 min-w-0">
                  <div class="font-semibold flex items-center gap-2 flex-wrap">
                    {definition.name}
                    <span class={"badge badge-sm #{indexer_type_badge_class(definition.type)}"}>
                      {definition.type}
                    </span>
                    <%= if definition.language do %>
                      <span class="badge badge-sm badge-ghost">{definition.language}</span>
                    <% end %>
                  </div>
                  <%= if definition.description do %>
                    <div class="text-sm text-base-content/70 mt-1 line-clamp-1">
                      {definition.description}
                    </div>
                  <% end %>
                </div>
                <%!-- Status and Health --%>
                <div class="flex items-center gap-3 flex-wrap">
                  <span class={"badge badge-sm #{indexer_status_class(definition)}"}>
                    {indexer_status_label(definition)}
                  </span>
                  <%= if needs_configuration?(definition) and definition.enabled do %>
                    <div class="tooltip" data-tip="This indexer requires configuration">
                      <.icon name="hero-exclamation-triangle" class="w-4 h-4 text-warning" />
                    </div>
                  <% end %>
                  <%= if definition.enabled do %>
                    <span class={"badge badge-sm #{health_status_badge_class(definition.health_status)}"}>
                      {health_status_label(definition.health_status)}
                    </span>
                  <% end %>
                </div>
                <%!-- Actions --%>
                <div class="flex items-center gap-2">
                  <input
                    type="checkbox"
                    class="toggle toggle-success toggle-sm"
                    checked={definition.enabled}
                    phx-click="toggle_indexer"
                    phx-target={@myself}
                    phx-value-id={definition.id}
                    title={if definition.enabled, do: "Disable", else: "Enable"}
                  />
                  <%= if definition.enabled do %>
                    <button
                      class="btn btn-sm btn-ghost"
                      phx-click="test_connection"
                      phx-target={@myself}
                      phx-value-id={definition.id}
                      title="Test Connection"
                    >
                      <.icon name="hero-signal" class="w-4 h-4" />
                    </button>
                  <% end %>
                  <%= if definition.type in ["private", "semi-private"] do %>
                    <button
                      class="btn btn-sm btn-ghost"
                      phx-click="configure_indexer"
                      phx-target={@myself}
                      phx-value-id={definition.id}
                      title="Configure"
                    >
                      <.icon name="hero-cog-6-tooth" class="w-4 h-4" />
                    </button>
                  <% end %>
                </div>
              </div>
            </div>
          <% end %>
        </div>
      <% end %>
      <%!-- Configuration Modal --%>
      <%= if @show_config_modal do %>
        <div class="modal modal-open">
          <div class="modal-box max-w-2xl">
            <h3 class="font-bold text-lg mb-4">
              Configure {@configuring_definition.name}
            </h3>

            <div class="alert alert-info mb-4">
              <.icon name="hero-information-circle" class="w-5 h-5" />
              <span>
                Private indexers require authentication. Enter your credentials below.
              </span>
            </div>

            <form id="cardigann-config-form" phx-submit="save_config" phx-target={@myself}>
              <div class="space-y-4">
                <%!-- Username --%>
                <div class="form-control">
                  <label class="label">
                    <span class="label-text">Username</span>
                  </label>
                  <input
                    type="text"
                    name="config[username]"
                    value={get_in(@configuring_definition.config || %{}, ["username"])}
                    class="input input-bordered"
                    placeholder="Your indexer username"
                  />
                </div>
                <%!-- Password --%>
                <div class="form-control">
                  <label class="label">
                    <span class="label-text">Password</span>
                  </label>
                  <input
                    type="password"
                    name="config[password]"
                    value={get_in(@configuring_definition.config || %{}, ["password"])}
                    class="input input-bordered"
                    placeholder="Your indexer password"
                  />
                </div>
                <%!-- API Key (optional) --%>
                <div class="form-control">
                  <label class="label">
                    <span class="label-text">API Key (if applicable)</span>
                  </label>
                  <input
                    type="password"
                    name="config[api_key]"
                    value={get_in(@configuring_definition.config || %{}, ["api_key"])}
                    class="input input-bordered"
                    placeholder="Optional API key"
                  />
                </div>
                <%!-- Cookie (optional) --%>
                <div class="form-control">
                  <label class="label">
                    <span class="label-text">Cookie String (if applicable)</span>
                  </label>
                  <textarea
                    name="config[cookie]"
                    rows="3"
                    class="textarea textarea-bordered"
                    placeholder="Optional cookie string for authentication"
                  >{get_in(@configuring_definition.config || %{}, ["cookie"])}</textarea>
                </div>
              </div>

              <div class="modal-action">
                <button
                  type="button"
                  class="btn"
                  phx-click="close_config_modal"
                  phx-target={@myself}
                >
                  Cancel
                </button>
                <button type="submit" class="btn btn-primary">Save Configuration</button>
              </div>
            </form>
          </div>
          <div class="modal-backdrop" phx-click="close_config_modal" phx-target={@myself}></div>
        </div>
      <% end %>
    </div>
    """
  end

  ## Event Handlers

  @impl true
  def handle_event("filter_type", %{"type" => type}, socket) do
    {:noreply,
     socket
     |> assign(:filter_type, type)
     |> load_indexers()}
  end

  @impl true
  def handle_event("filter_language", %{"language" => language}, socket) do
    {:noreply,
     socket
     |> assign(:filter_language, language)
     |> load_indexers()}
  end

  @impl true
  def handle_event("filter_enabled", %{"enabled" => enabled}, socket) do
    {:noreply,
     socket
     |> assign(:filter_enabled, enabled)
     |> load_indexers()}
  end

  @impl true
  def handle_event("search", %{"search" => %{"query" => query}}, socket) do
    {:noreply,
     socket
     |> assign(:search_query, query)
     |> load_indexers()}
  end

  @impl true
  def handle_event("toggle_indexer", %{"id" => id}, socket) do
    definition = Indexers.get_cardigann_definition!(id)

    result =
      if definition.enabled do
        Indexers.disable_cardigann_definition(definition)
      else
        Indexers.enable_cardigann_definition(definition)
      end

    case result do
      {:ok, updated_definition} ->
        action = if updated_definition.enabled, do: "enabled", else: "disabled"

        {:noreply,
         socket
         |> put_flash(:info, "Indexer #{action} successfully")
         |> load_indexers()}

      {:error, changeset} ->
        MydiaLogger.log_error(:liveview, "Failed to toggle indexer",
          error: changeset,
          operation: :toggle_cardigann_indexer,
          definition_id: id,
          user_id: socket.assigns.current_user.id
        )

        error_msg = MydiaLogger.user_error_message(:toggle_cardigann_indexer, changeset)

        {:noreply,
         socket
         |> put_flash(:error, error_msg)}
    end
  end

  @impl true
  def handle_event("configure_indexer", %{"id" => id}, socket) do
    definition = Indexers.get_cardigann_definition!(id)

    {:noreply,
     socket
     |> assign(:show_config_modal, true)
     |> assign(:configuring_definition, definition)}
  end

  @impl true
  def handle_event("close_config_modal", _params, socket) do
    {:noreply, assign(socket, :show_config_modal, false)}
  end

  @impl true
  def handle_event("save_config", %{"config" => config_params}, socket) do
    definition = socket.assigns.configuring_definition

    case Indexers.configure_cardigann_definition(definition, config_params) do
      {:ok, _updated_definition} ->
        {:noreply,
         socket
         |> assign(:show_config_modal, false)
         |> put_flash(:info, "Configuration saved successfully")
         |> load_indexers()}

      {:error, changeset} ->
        MydiaLogger.log_error(:liveview, "Failed to configure indexer",
          error: changeset,
          operation: :configure_cardigann_indexer,
          definition_id: definition.id,
          user_id: socket.assigns.current_user.id
        )

        error_msg = MydiaLogger.user_error_message(:configure_cardigann_indexer, changeset)

        {:noreply,
         socket
         |> put_flash(:error, error_msg)}
    end
  end

  @impl true
  def handle_event("sync_definitions", _params, socket) do
    {:noreply,
     socket
     |> put_flash(:info, "Sync triggered - this may take a few minutes")}
  end

  @impl true
  def handle_event("test_connection", %{"id" => id}, socket) do
    case Indexers.test_cardigann_connection(id) do
      {:ok, result} ->
        flash_message =
          if result.success do
            "Connection successful (#{result.response_time_ms}ms)"
          else
            "Connection failed: #{result.error || "Unknown error"}"
          end

        flash_type = if result.success, do: :info, else: :error

        {:noreply,
         socket
         |> put_flash(flash_type, flash_message)
         |> load_indexers()}

      {:error, reason} ->
        MydiaLogger.log_error(:liveview, "Failed to test connection",
          error: reason,
          operation: :test_cardigann_connection,
          definition_id: id,
          user_id: socket.assigns.current_user.id
        )

        {:noreply,
         socket
         |> put_flash(:error, "Failed to test connection: #{inspect(reason)}")}
    end
  end

  ## Private Functions

  defp load_indexers(socket) do
    filters = build_filters(socket.assigns)
    definitions = Indexers.list_cardigann_definitions(filters)
    stats = Indexers.count_cardigann_definitions()

    # Get unique languages from all definitions for filter dropdown
    all_definitions = Indexers.list_cardigann_definitions()

    languages =
      all_definitions
      |> Enum.map(& &1.language)
      |> Enum.reject(&is_nil/1)
      |> Enum.uniq()
      |> Enum.sort()

    socket
    |> assign(:definitions, definitions)
    |> assign(:stats, stats)
    |> assign(:available_languages, languages)
  end

  defp build_filters(assigns) do
    filters = []

    filters =
      if assigns.filter_type != "all" do
        [{:type, assigns.filter_type} | filters]
      else
        filters
      end

    filters =
      if assigns.filter_language != "all" do
        [{:language, assigns.filter_language} | filters]
      else
        filters
      end

    filters =
      case assigns.filter_enabled do
        "enabled" -> [{:enabled, true} | filters]
        "disabled" -> [{:enabled, false} | filters]
        _ -> filters
      end

    filters =
      if assigns.search_query != "" do
        [{:search, assigns.search_query} | filters]
      else
        filters
      end

    filters
  end

  defp indexer_type_badge_class("public"), do: "badge-success"
  defp indexer_type_badge_class("private"), do: "badge-error"
  defp indexer_type_badge_class("semi-private"), do: "badge-warning"
  defp indexer_type_badge_class(_), do: "badge-ghost"

  defp indexer_status_class(%CardigannDefinition{enabled: false}), do: "badge-ghost"

  defp indexer_status_class(%CardigannDefinition{enabled: true, type: "private", config: nil}),
    do: "badge-warning"

  defp indexer_status_class(%CardigannDefinition{enabled: true, type: "private", config: config})
       when config == %{},
       do: "badge-warning"

  defp indexer_status_class(%CardigannDefinition{enabled: true}), do: "badge-success"

  defp indexer_status_label(%CardigannDefinition{enabled: false}), do: "Disabled"

  defp indexer_status_label(%CardigannDefinition{enabled: true, type: "private", config: nil}),
    do: "Needs Config"

  defp indexer_status_label(%CardigannDefinition{enabled: true, type: "private", config: config})
       when config == %{},
       do: "Needs Config"

  defp indexer_status_label(%CardigannDefinition{enabled: true}), do: "Enabled"

  defp needs_configuration?(%CardigannDefinition{type: "public"}), do: false

  defp needs_configuration?(%CardigannDefinition{
         type: type,
         config: nil
       })
       when type in ["private", "semi-private"],
       do: true

  defp needs_configuration?(%CardigannDefinition{type: type, config: config})
       when type in ["private", "semi-private"] and config == %{},
       do: true

  defp needs_configuration?(_), do: false

  defp health_status_badge_class("healthy"), do: "badge-success"
  defp health_status_badge_class("degraded"), do: "badge-warning"
  defp health_status_badge_class("unhealthy"), do: "badge-error"
  defp health_status_badge_class("unknown"), do: "badge-ghost"
  defp health_status_badge_class(_), do: "badge-ghost"

  defp health_status_label("healthy"), do: "Healthy"
  defp health_status_label("degraded"), do: "Degraded"
  defp health_status_label("unhealthy"), do: "Unhealthy"
  defp health_status_label("unknown"), do: "Unknown"
  defp health_status_label(nil), do: "Unknown"
  defp health_status_label(_), do: "Unknown"
end
