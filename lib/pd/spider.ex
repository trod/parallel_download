defmodule PD.Spider do
  @moduledoc """
    Core logic of web spider
  """

  @spec run(list()) :: list()
  def run(urls) when is_list(urls) do
    urls
    |> Enum.chunk_every(batch_size())
    |> Enum.map(&process_batch/1)
    |> List.flatten()
  end

  def run(_urls), do: []

  defp process_batch(batch) do
    batch
    |> Enum.reduce([], fn url, acc ->
      [{url, Task.async(fn -> download(url) end)} | acc]
    end)
    |> Enum.map(fn {url, task} ->
      try do
        Task.await(task, timeout())
      catch
        :exit, _ -> {:timeout, url}
      end
    end)
  end

  defp download(url) when is_binary(url) do
    res =
      measure(fn -> PD.HTTP.get(url) end)
      |> case do
        {time, {:ok, %Finch.Response{status: status}}} -> {time, url, status}
        {_time, {:error, %{message: msg}}} -> {:ignored, url, msg}
        {time, {:error, %{reason: reason}}} -> {time, url, reason}
        {time, err} -> {time, url, err}
      end

    # just to print rout a result as soon as possible
    IO.puts("#{inspect(res)}")

    res
  end

  defp download(url), do: {0, url, "not a url"}

  defp measure(function) do
    {time, res} =
      function
      |> :timer.tc()

    {time / 1_000, res}
  end

  defp timeout do
    Application.get_env(:pd, __MODULE__)[:timeout]
  end

  defp batch_size do
    Application.get_env(:pd, __MODULE__)[:batch_size]
  end
end
