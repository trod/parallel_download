defmodule Mix.Tasks.Runner do
  @moduledoc "Parallel download. Example: `mix runner http://google.com http://bing.com"
  @shortdoc "Parallel download"

  use Mix.Task

  @impl Mix.Task
  def run(args) do
    {:ok, _started} = Application.ensure_all_started(:pd)
    args
    |> PD.Spider.run()
  end
end
