defmodule PD.HTTP do
  @moduledoc """
    Functions to perform http requests
  """

  def get(url) do
    try do
      Finch.build(:get, url)
      |> Finch.request(__MODULE__)
    rescue
      e in ArgumentError -> {:error, e}
    end
  end
end
