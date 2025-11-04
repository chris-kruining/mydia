# Mydia

A Phoenix-based media management application.

## Getting Started

### Docker Development (Recommended)

The easiest way to get started is using the `./dev` wrapper script with Docker Compose:

```bash
# Start the development environment
./dev up -d

# Run database migrations
./dev mix ecto.migrate

# Open an interactive shell
./dev shell

# Run tests
./dev test

# View logs
./dev logs -f

# Stop the environment
./dev down
```

Run `./dev` without arguments to see all available commands.

### Local Development

To run Phoenix locally without Docker:

* Run `mix setup` to install and setup dependencies
* Start Phoenix endpoint with `mix phx.server` or inside IEx with `iex -S mix phx.server`

Now you can visit [`localhost:4000`](http://localhost:4000) from your browser.

Ready to run in production? Please [check our deployment guides](https://hexdocs.pm/phoenix/deployment.html).

## Learn more

* Official website: https://www.phoenixframework.org/
* Guides: https://hexdocs.pm/phoenix/overview.html
* Docs: https://hexdocs.pm/phoenix
* Forum: https://elixirforum.com/c/phoenix-forum
* Source: https://github.com/phoenixframework/phoenix
