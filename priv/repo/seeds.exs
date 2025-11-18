# Script for populating the database. You can run it as:
#
#     mix run priv/repo/seeds.exs
#
# Inside the script, you can read and write to any of your
# repositories directly:
#
#     Mydia.Repo.insert!(%Mydia.SomeSchema{})
#
# We recommend using the bang functions (`insert!`, `update!`
# and so on) as they will fail if something goes wrong.

alias Mydia.Accounts

# Create default admin user for development and test environments
if Mix.env() in [:dev, :test] do
  case Accounts.get_user_by_username("admin") do
    nil ->
      {:ok, _user} =
        Accounts.create_user(%{
          username: "admin",
          email: "admin@localhost",
          password: "adminpass",
          role: "admin",
          display_name: "Administrator"
        })

      IO.puts("✓ Created default admin user (username: admin, password: adminpass)")

    _user ->
      IO.puts("⊘ Default admin user already exists, skipping creation")
  end

  # Create default test user for E2E tests
  case Accounts.get_user_by_username("testuser") do
    nil ->
      {:ok, _user} =
        Accounts.create_user(%{
          username: "testuser",
          email: "testuser@example.com",
          password: "testpass",
          role: "user",
          display_name: "Test User"
        })

      IO.puts("✓ Created test user (username: testuser, password: testpass)")

    _user ->
      IO.puts("⊘ Test user already exists, skipping creation")
  end
end
