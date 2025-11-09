defmodule MydiaWeb.MyRequestsLive.Index do
  use MydiaWeb, :live_view

  alias Mydia.MediaRequests

  @impl true
  def mount(_params, _session, socket) do
    {:ok,
     socket
     |> assign(:page_title, "My Requests")
     |> assign(:filter_status, "all")
     |> load_requests()}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_filters(socket, params)}
  end

  ## Event Handlers

  @impl true
  def handle_event("filter", %{"status" => status}, socket) do
    {:noreply, push_patch(socket, to: ~p"/requests?status=#{status}")}
  end

  ## Private Helpers

  defp apply_filters(socket, params) do
    status = params["status"] || "all"

    socket
    |> assign(:filter_status, status)
    |> load_requests()
  end

  defp load_requests(socket) do
    user_id = socket.assigns.current_user.id

    opts = [
      requester_id: user_id,
      preload: [:requester, :approved_by, :media_item]
    ]

    opts =
      case socket.assigns.filter_status do
        "all" -> opts
        status -> Keyword.put(opts, :status, status)
      end

    requests = MediaRequests.list_requests(opts)

    assign(socket, :requests, requests)
  end

  defp format_date(nil), do: "N/A"

  defp format_date(%DateTime{} = dt) do
    Calendar.strftime(dt, "%b %d, %Y at %I:%M %p")
  end

  defp status_badge_class("pending"), do: "badge-warning"
  defp status_badge_class("approved"), do: "badge-success"
  defp status_badge_class("rejected"), do: "badge-error"
  defp status_badge_class(_), do: "badge-ghost"

  defp status_text("pending"), do: "Pending Review"
  defp status_text("approved"), do: "Approved"
  defp status_text("rejected"), do: "Rejected"
  defp status_text(_), do: "Unknown"
end
