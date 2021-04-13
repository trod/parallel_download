defmodule PD.SpiderTest do
  use ExUnit.Case, async: true
  alias PD.Spider
  alias PD.HTTP

  import Mock

  test "empty list of urls" do
    urls = []
    Spider.run(urls)
    assert [] == Spider.run(urls)
  end

  test "correct url" do
    google_url = "http://google.com"
    urls = [google_url]

    with_mocks([
      {HTTP, [], [get: fn _ -> {:ok, %Finch.Response{status: 301}} end]}
    ]) do
      assert [{n, google_url, 301}] = Spider.run(urls)
      assert is_number(n)
      assert_called(HTTP.get(google_url))
    end
  end

  test "invalid url is ignored" do
    invalid_url = "htpp://google.com"
    urls = [invalid_url]

    with_mocks([
      {HTTP, [],
       [
         get: fn _ ->
           {:error, %ArgumentError{message: "invalid scheme \"htpp\" for url: " <> invalid_url}}
         end
       ]}
    ]) do
      assert [{:ignored, ^invalid_url, "invalid scheme \"htpp\" for url: htpp://google.com"}] =
               Spider.run(urls)

      assert_called(HTTP.get(invalid_url))
    end
  end

  test "url is not a string" do
    invalid_url = 123
    urls = [invalid_url]

    assert [{0, invalid_url, "not a url"}] == Spider.run(urls)
  end

  test "http error is correctly handled" do
    google_url = "http://google.com"
    urls = [google_url]

    with_mocks([
      {HTTP, [],
       [
         get: fn _ ->
           {:error, %Mint.TransportError{reason: :nxdomain}}
         end
       ]}
    ]) do
      assert [{_t, ^google_url, :nxdomain}] = Spider.run(urls)
      assert_called(HTTP.get(google_url))
    end
  end

  test "list of correct urls" do
    google_url = "http://google.com"
    urls = [google_url, google_url, google_url]

    with_mocks([
      {HTTP, [], [get: fn _ -> {:ok, %Finch.Response{status: 301}} end]}
    ]) do
      assert [
               {_t1, "http://google.com", 301},
               {_t2, "http://google.com", 301},
               {_t3, "http://google.com", 301}
             ] = Spider.run(urls)

      assert_called(HTTP.get(google_url))
    end
  end

  test "not a list of urls" do
    urls = "google_url"

    assert [] == Spider.run(urls)
  end

  test "correcty handles timeout" do
    google_url = "http://google.com"
    # timeout is 500ms
    idle_time = 600
    urls = [google_url]

    with_mocks([
      {HTTP, [], [get: fn _ -> :timer.sleep(idle_time) end]}
    ]) do
      assert [
               {:timeout, "http://google.com"}
             ] = Spider.run(urls)
    end
  end
end
