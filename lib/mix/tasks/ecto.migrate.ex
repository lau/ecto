defmodule Mix.Tasks.Ecto.Migrate do
  use Mix.Task
  import Mix.Ecto

  @shortdoc "Runs migrations up on a repo"

  @moduledoc """
  Runs the pending migrations for the given repository.

  By default, migrations are expected at "priv/YOUR_REPO/migrations"
  directory of the current application but it can be configured
  by specify the `:priv` key under the repository configuration.

  Runs all pending migrations by default. To migrate up
  to a version number, supply `--to version_number`.
  To migrate up a specific number of times, use `--step n`.

  ## Examples

      mix ecto.migrate
      mix ecto.migrate -r Custom.Repo

      mix ecto.migrate -n 3
      mix ecto.migrate --step 3

      mix ecto.migrate -v 20080906120000
      mix ecto.migrate --to 20080906120000

  ## Command line options

    * `-r`, `--repo` - the repo to migrate (defaults to `YourApp.Repo`)
    * `--all` - run all pending migrations
    * `--step` / `-n` - run n number of pending migrations
    * `--to` / `-v` - run all migrations up to and including version
    * `--no-start` - do not start applications
  """

  @doc false
  def run(args, migrator \\ &Ecto.Migrator.run/4) do
    Mix.Task.run "app.start", args
    repo = parse_repo(args)

    {opts, _, _} = OptionParser.parse args,
      switches: [all: :boolean, step: :integer, to: :integer, start: :boolean],
      aliases: [n: :step, v: :to]

    ensure_repo(repo)
    if Keyword.get(opts, :start, true), do: ensure_started(repo)

    unless opts[:to] || opts[:step] || opts[:all] do
      opts = Keyword.put(opts, :all, true)
    end

    migrator.(repo, migrations_path(repo), :up, opts)
  end
end
