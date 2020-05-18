defmodule PollutionDataStream do
  @moduledoc false

  def importLinesFromCSV(path) do
    list = File.stream!(path) |> Stream.map(&parseLine(&1)) |> Enum.to_list

    if length(list) >= 5900 do
      IO.puts("success! at least 5900 measurements were loaded! - #{length(list)} to be precise")
    else
      IO.puts("mission failed! less than 5900 measurements were loaded! - #{length(list)} to be precise")
    end
    list
  end

  def parseLine(line) do
    [date, time, lon, lat, value] = String.split(line, ",")
    date = String.split(date, "-") |> Enum.reverse |> Stream.map(&(Integer.parse(&1) |> elem(0))) |> Enum.reduce({}, fn(element, tuple) -> Tuple.append(tuple, element) end)
    time = String.split(time, ":") |> Stream.map(&(Integer.parse(&1) |> elem(0))) |> Enum.reduce({}, fn(element, tuple) -> Tuple.append(tuple, element) end) |> Tuple.append(0)
    lon = Float.parse(lon) |> elem(0)
    lat = Float.parse(lat) |> elem(0)
    value = Integer.parse(value) |> elem(0)

    %{:datetime => {date, time}, :location => {lon, lat}, :value => value}
  end

  def identifyStations(list) do
    stations = Enum.uniq_by(list, &(&1.location)) |> Enum.map(&(&1.location))

    if length(stations) == 1 do
      IO.puts("found 1 distinct station")
    else
      if length(stations) > 1 do
        IO.puts("found #{length(stations)} distinct stations")
      else
        IO.puts("no station found")
      end
    end
    stations
  end

  def addStations([]), do: :ok
  def addStations([location | tail]) do
    stationName = 'station_#{location |> elem(0)}_#{location |> elem(1)}'
    :pollution_gen_server.addStation(stationName, location)
    addStations(tail)
  end

  def addValues([]), do: :ok
  def addValues([reading | tail]) do
    :pollution_gen_server.addValue(reading.location, reading.datetime, 'PM10', reading.value)
    addValues(tail)
  end

  def loadData(path) do
    addStations = fn () -> importLinesFromCSV(path) |> identifyStations() |> addStations() end
    addValues = fn () -> importLinesFromCSV(path) |> addValues() end

    IO.puts("#{ addStations |> :timer.tc([]) |> elem(0)} microseconds")
    IO.puts("#{ addValues |> :timer.tc([]) |> elem(0)} microseconds")
  end

  def analyzeData() do
    stationMean = fn () -> :pollution_gen_server.getStationMean('station_20.06_49.986', 'PM10') end
    dailyMean = fn () -> :pollution_gen_server.getDailyMean('PM10', {2017, 5, 3}) end
    IO.puts("#{ stationMean |> :timer.tc([]) |> elem(0)} microseconds")
    IO.puts("#{ dailyMean |> :timer.tc([]) |> elem(0)} microseconds")
  end

end
