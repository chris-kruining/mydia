#!/bin/sh
set -e

echo "🌱 Seeding test users for E2E tests..."

# Wait for the application to be ready
echo "⏳ Waiting for application to be ready..."
for i in $(seq 1 30); do
    if curl -sf http://localhost:4000/health > /dev/null 2>&1; then
        echo "✓ Application is ready!"
        break
    fi
    echo "  Waiting... ($i/30)"
    sleep 2
done

# Create admin user
echo "👤 Creating admin user..."
/app/bin/mydia rpc '
case Mydia.Accounts.get_user_by_username("admin") do
  nil ->
    Mydia.Accounts.create_user(%{
      username: "admin",
      email: "admin@localhost",
      password: "adminpass",
      role: "admin",
      display_name: "Administrator"
    })
    IO.puts("✓ Admin user created")
  _ ->
    IO.puts("⊘ Admin user already exists")
    :ok
end
' || echo "⚠ Failed to create admin user, but continuing..."

# Create test user
echo "👤 Creating test user..."
/app/bin/mydia rpc '
case Mydia.Accounts.get_user_by_username("testuser") do
  nil ->
    Mydia.Accounts.create_user(%{
      username: "testuser",
      email: "testuser@example.com",
      password: "testpass",
      role: "user",
      display_name: "Test User"
    })
    IO.puts("✓ Test user created")
  _ ->
    IO.puts("⊘ Test user already exists")
    :ok
end
' || echo "⚠ Failed to create test user, but continuing..."

echo "✅ Test user seeding complete!"
