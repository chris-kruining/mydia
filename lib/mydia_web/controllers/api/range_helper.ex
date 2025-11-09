defmodule MydiaWeb.Api.RangeHelper do
  @moduledoc """
  Helper functions for handling HTTP Range requests.

  Supports parsing Range headers and generating appropriate response headers
  for HTTP 206 Partial Content responses.
  """

  @doc """
  Parses an HTTP Range header value.

  Returns {:ok, start, end_pos} for valid ranges or :error for invalid ones.
  Only supports single byte ranges in the format "bytes=START-END" or "bytes=START-".

  ## Examples

      iex> parse_range_header("bytes=0-499", 1000)
      {:ok, 0, 499}

      iex> parse_range_header("bytes=500-", 1000)
      {:ok, 500, 999}

      iex> parse_range_header("bytes=invalid", 1000)
      :error
  """
  def parse_range_header(nil, _file_size), do: :error
  def parse_range_header("", _file_size), do: :error

  def parse_range_header(range_header, file_size) do
    # Only support single byte range requests
    case String.split(range_header, "=") do
      ["bytes", range_spec] ->
        parse_range_spec(range_spec, file_size)

      _ ->
        :error
    end
  end

  defp parse_range_spec(spec, file_size) do
    case String.split(spec, "-") do
      [start_str, ""] ->
        # Range like "bytes=500-" (from position to end)
        with {start, ""} <- Integer.parse(start_str),
             true <- start >= 0 and start < file_size do
          {:ok, start, file_size - 1}
        else
          _ -> :error
        end

      [start_str, end_str] ->
        # Range like "bytes=0-499"
        with {start, ""} <- Integer.parse(start_str),
             {end_pos, ""} <- Integer.parse(end_str),
             true <- start >= 0 and start <= end_pos and end_pos < file_size do
          {:ok, start, end_pos}
        else
          _ -> :error
        end

      _ ->
        :error
    end
  end

  @doc """
  Calculates the byte range to serve based on start and end positions.

  Returns {offset, length} tuple where:
  - offset: byte position to start reading from
  - length: number of bytes to read

  ## Examples

      iex> calculate_range(0, 499)
      {0, 500}

      iex> calculate_range(500, 999)
      {500, 500}
  """
  def calculate_range(start, end_pos) when start <= end_pos do
    {start, end_pos - start + 1}
  end

  @doc """
  Formats a Content-Range header value.

  ## Examples

      iex> format_content_range(0, 499, 1000)
      "bytes 0-499/1000"

      iex> format_content_range(500, 999, 1000)
      "bytes 500-999/1000"
  """
  def format_content_range(start, end_pos, total) do
    "bytes #{start}-#{end_pos}/#{total}"
  end

  @doc """
  Gets MIME type from file extension.

  ## Examples

      iex> get_mime_type("/path/to/movie.mp4")
      "video/mp4"

      iex> get_mime_type("/path/to/movie.mkv")
      "video/x-matroska"
  """
  def get_mime_type(path) do
    extension =
      path
      |> Path.extname()
      |> String.downcase()

    case extension do
      ".mp4" -> "video/mp4"
      ".m4v" -> "video/x-m4v"
      ".mkv" -> "video/x-matroska"
      ".avi" -> "video/x-msvideo"
      ".webm" -> "video/webm"
      ".mov" -> "video/quicktime"
      ".wmv" -> "video/x-ms-wmv"
      ".flv" -> "video/x-flv"
      ".ts" -> "video/mp2t"
      _ -> "video/mp4"
    end
  end
end
