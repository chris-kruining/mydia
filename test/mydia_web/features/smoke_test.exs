defmodule MydiaWeb.Features.SmokeTest do
  @moduledoc """
  Smoke tests to verify the Phoenix application is working correctly.

  These tests run in a real browser and verify:
  - Basic page loading
  - HTML structure
  - LiveView JavaScript loading
  - Alpine.js initialization

  Converted from assets/e2e/tests/smoke.spec.ts
  """

  use MydiaWeb.FeatureCase, async: false

  @moduletag :feature

  describe "Application Smoke Test" do
    @tag :feature
    test "homepage redirects to login when not authenticated", %{session: session} do
      session
      |> visit("/")
      # Unauthenticated users are redirected to login
      |> assert_path("/auth/local/login")
    end

    @tag :feature
    test "login page loads successfully", %{session: session} do
      session
      |> visit("/auth/local/login")
      |> assert_path("/auth/local/login")
      |> assert_has_text("Sign in")
    end

    @tag :feature
    test "page has proper HTML structure", %{session: session} do
      session
      |> visit("/auth/local/login")

      # Check for basic HTML structure - title should exist
      title = Wallaby.Browser.page_title(session)
      assert title != nil
      assert String.length(title) > 0
    end

    @tag :feature
    test "LiveView JavaScript is loaded", %{session: session} do
      # Create and login a user first so we can access authenticated pages
      login_as_admin(session)

      # Wait for page to load and check for LiveView elements
      session
      |> visit("/")
      |> wait_for_liveview()

      # Verify LiveView is connected by checking for phx-* attributes
      assert Wallaby.Browser.has_css?(session, "[data-phx-main]")
    end

    @tag :feature
    test "can reload page and maintain URL", %{session: session} do
      session
      |> visit("/auth/local/login")
      |> assert_path("/auth/local/login")

      # Get the initial URL
      initial_path = Wallaby.Browser.current_path(session)

      # Reload the page
      session = Wallaby.Browser.visit(session, "/auth/local/login")

      # Verify we're still on the same path
      assert Wallaby.Browser.current_path(session) == initial_path
    end
  end
end
