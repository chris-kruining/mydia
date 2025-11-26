defmodule MydiaWeb.Features.AuthTest do
  @moduledoc """
  Feature tests for authentication and authorization flows.

  Tests cover:
  - Local authentication (username/password)
  - Session persistence
  - Protected route access
  - Role-based authorization

  Converted from assets/e2e/tests/auth.spec.ts
  """

  use MydiaWeb.FeatureCase, async: false

  @moduletag :feature

  describe "Local Authentication" do
    @tag :feature
    test "can login with valid credentials", %{session: session} do
      user = create_admin_user()

      session
      |> visit("/auth/local/login")
      |> fill_in(Query.text_field("user[username]"), with: user.username)
      |> fill_in(Query.text_field("user[password]"), with: "password123")
      |> click(Query.button("Sign in"))
      |> assert_path("/")
      |> assert_has_text("Dashboard")
    end

    @tag :feature
    test "shows error message with invalid credentials", %{session: session} do
      session
      |> visit("/auth/local/login")
      |> fill_in(Query.text_field("user[username]"), with: "invalid")
      |> fill_in(Query.text_field("user[password]"), with: "wrong-password")
      |> click(Query.button("Sign in"))
      # Should stay on login page
      |> assert_path("/auth/local/login")

      # Should show an error message
      assert Wallaby.Browser.has_css?(session, "[role='alert'], .alert")
    end

    @tag :feature
    test "can logout successfully", %{session: session} do
      # Login first
      login_as_admin(session)
      |> assert_path("/")

      # Logout
      session
      |> visit("/auth/logout")

      # Should redirect to login page
      assert Wallaby.Browser.current_path(session) =~ ~r/\/auth\/(local\/)?login/
    end
  end

  describe "Session Persistence" do
    @tag :feature
    test "maintains session across page reloads", %{session: session} do
      # Login
      login_as_admin(session)
      |> assert_path("/")

      # Reload the page
      session = Wallaby.Browser.visit(session, "/")

      # Should still be logged in (not redirected to login)
      assert_path(session, "/")
      assert Wallaby.Browser.has_text?(session, "Dashboard")
    end

    @tag :feature
    test "maintains session across navigation", %{session: session} do
      # Login
      login_as_admin(session)
      |> assert_path("/")

      # Navigate to different pages
      session
      |> visit("/media")
      |> assert_path("/media")

      assert Wallaby.Browser.has_text?(session, "Dashboard")

      session
      |> visit("/downloads")
      |> assert_path("/downloads")

      assert Wallaby.Browser.has_text?(session, "Dashboard")
    end
  end

  describe "Protected Routes" do
    @tag :feature
    test "redirects to login when accessing protected route without auth", %{session: session} do
      # Try to access dashboard without logging in
      session
      |> visit("/")

      # Should be redirected to login page
      assert Wallaby.Browser.current_path(session) =~ ~r/\/auth\/(local\/)?login/
    end

    @tag :feature
    test "redirects to login when accessing media page without auth", %{session: session} do
      session
      |> visit("/media")

      # Should be redirected to login page
      assert Wallaby.Browser.current_path(session) =~ ~r/\/auth\/(local\/)?login/
    end

    @tag :feature
    test "redirects to login when accessing downloads page without auth", %{session: session} do
      session
      |> visit("/downloads")

      # Should be redirected to login page
      assert Wallaby.Browser.current_path(session) =~ ~r/\/auth\/(local\/)?login/
    end

    @tag :feature
    test "allows access to protected route after login", %{session: session} do
      # Login first
      login_as_admin(session)

      # Should be able to access protected routes
      session
      |> visit("/media")
      |> assert_path("/media")

      session
      |> visit("/downloads")
      |> assert_path("/downloads")

      session
      |> visit("/calendar")
      |> assert_path("/calendar")
    end
  end

  describe "Role-Based Authorization" do
    @tag :feature
    test "admin can access admin pages", %{session: session} do
      # Login as admin
      login_as_admin(session)

      # Navigate to admin page
      session
      |> visit("/admin")

      # Should be able to access admin page (URL should contain /admin)
      assert Wallaby.Browser.current_path(session) =~ ~r/\/admin/

      # Should see admin content (not access denied)
      refute Wallaby.Browser.has_text?(session, "Access Denied")
    end

    @tag :feature
    test "admin can access admin config pages", %{session: session} do
      # Login as admin
      login_as_admin(session)

      # Navigate to admin config page
      session
      |> visit("/admin/config")
      |> assert_path("/admin/config")
    end

    @tag :feature
    test "admin can access admin users page", %{session: session} do
      # Login as admin
      login_as_admin(session)

      # Navigate to admin users page
      session
      |> visit("/admin/users")
      |> assert_path("/admin/users")
    end

    @tag :feature
    test "regular user cannot access admin pages", %{session: session} do
      # Login as regular user
      login_as_user(session)

      # Try to access admin page
      session
      |> visit("/admin")

      # Wait for potential redirect
      Process.sleep(500)

      # Should be redirected away from admin page
      refute Wallaby.Browser.current_path(session) == "/admin"
    end

    @tag :feature
    test "regular user can access non-admin protected pages", %{session: session} do
      # Login as regular user
      login_as_user(session)

      # Should be able to access regular protected routes
      session
      |> visit("/media")
      |> assert_path("/media")

      session
      |> visit("/downloads")
      |> assert_path("/downloads")
    end
  end

  describe "Navigation Flow" do
    @tag :feature
    test "can access intended page after login", %{session: session} do
      # Try to access a protected page without being logged in
      session
      |> visit("/calendar")

      # Should be redirected to login
      assert Wallaby.Browser.current_path(session) =~ ~r/\/auth\/(local\/)?login/

      # Login
      user = create_admin_user()

      session
      |> fill_in(Query.text_field("user[username]"), with: user.username)
      |> fill_in(Query.text_field("user[password]"), with: "password123")
      |> click(Query.button("Sign in"))

      # After login, navigate to the intended page
      session
      |> visit("/calendar")
      |> assert_path("/calendar")
    end
  end

  describe "Auto-Promotion" do
    @tag :feature
    test "local auth users maintain their assigned roles", %{session: session} do
      admin_user = create_admin_user()
      regular_user = create_test_user()

      # Login as admin user
      session
      |> visit("/auth/local/login")
      |> fill_in(Query.text_field("user[username]"), with: admin_user.username)
      |> fill_in(Query.text_field("user[password]"), with: "password123")
      |> click(Query.button("Sign in"))
      |> assert_path("/")

      # Verify admin can access admin pages
      session
      |> visit("/admin")

      assert Wallaby.Browser.current_path(session) =~ ~r/\/admin/

      # Logout
      session
      |> visit("/auth/logout")

      assert Wallaby.Browser.current_path(session) =~ ~r/\/auth\/(local\/)?login/

      # Login as regular user
      session
      |> visit("/auth/local/login")
      |> fill_in(Query.text_field("user[username]"), with: regular_user.username)
      |> fill_in(Query.text_field("user[password]"), with: "password123")
      |> click(Query.button("Sign in"))
      |> assert_path("/")

      # Verify regular user cannot access admin pages
      session
      |> visit("/admin")

      # Wait for potential redirect
      Process.sleep(500)

      refute Wallaby.Browser.current_path(session) == "/admin"
    end
  end
end
