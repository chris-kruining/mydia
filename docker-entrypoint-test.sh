#!/bin/sh
set -e

# Start the main application in the background
/docker-entrypoint.sh "$@" &
APP_PID=$!

# Wait for the application to be ready
echo "Waiting for application to start..."
for i in $(seq 1 30); do
    if curl -sf http://localhost:4000/health > /dev/null 2>&1; then
        echo "Application is ready!"
        break
    fi
    echo "Waiting... ($i/30)"
    sleep 2
done

# Seed test users
echo "Seeding test users..."
/app/bin/mydia rpc '(fn -> alias Mydia.Accounts; case Accounts.get_user_by_username("admin") do nil -> Accounts.create_user(%{username: "admin", email: "admin@localhost", password: "adminpass", role: "admin", display_name: "Administrator"}); _ -> :ok end; case Accounts.get_user_by_username("testuser") do nil -> Accounts.create_user(%{username: "testuser", email: "testuser@example.com", password: "testpass", role: "user", display_name: "Test User"}); _ -> :ok end end).()' || echo "Seeding may have failed, but continuing..."

echo "Test environment is ready!"

# Wait for the application process
wait $APP_PID
