defmodule TodoList do
  @moduledoc """
  Simple todo-list
  """
  defimpl(String.Chars, do: def(to_string(this), do: inspect(this)))

  @typedoc "The type of todolist"
  @type t :: %{
          __struct__: TodoList,
          auto_id: number(),
          entries: map()
        }

  defstruct auto_id: 1, entries: %{}


  @doc """
  Create new Todo list. Empty if without params, or from initial list.
  ## Examples
      iex> TodoList.new()
      %TodoList{auto_id: 1, entries: %{}}
  """
  @spec new(any) :: Todolist.t() # fix any
  def new(entries \\ []) do
    Enum.reduce(
      entries,
      %TodoList{},
      &add_entry(&2, &1)
    )
  end

  @doc """
  Add something to todo-list.
  ## Examples
      iex> TodoList.new() |> TodoList.add_entry(%{date: ~D[2021-12-19], title: "job"})
      %TodoList{auto_id: 2, entries: %{1 => %{date: ~D[2021-12-19], id: 1, title: "job"}}}
  """
  @spec add_entry(TodoList.t(), map) :: TodoList.t()
  def add_entry(todo_list, entry) do
    entry = Map.put(entry, :id, todo_list.auto_id)
    new_entries = Map.put(todo_list.entries, todo_list.auto_id, entry)

    %TodoList{todo_list | entries: new_entries, auto_id: todo_list.auto_id + 1}
  end

  @doc """
  Show current todo-list.
  ## Examples
      iex> TodoList.new()
      ...(1)> |> TodoList.add_entry(%{date: ~D[2021-12-19], title: "job"})
      ...(1)> |> TodoList.add_entry(%{date: ~D[2021-12-19], title: "vacation"})
      %TodoList{auto_id: 3, entries: %{
        1 => %{date: ~D[2021-12-19], id: 1, title: "job"},
        2 => %{date: ~D[2021-12-19], id: 2, title: "vacation"}}}
  """
  @spec entries(TodoList.t(), any) :: list
  def entries(todo_list, date) do
    todo_list.entries
    |> Stream.filter(fn {_, entry} -> entry.date == date end)
    |> Enum.map(fn {_, entry} -> entry end)
  end

  @doc """
  Update Entry in todo-list by entry.
  ## Examples
      iex> TodoList.new()
      ...(1)> |> TodoList.add_entry(%{date: ~D[2021-12-19], title: "job"})
      ...(1)> |> TodoList.add_entry(%{date: ~D[2021-12-19], title: "vacation"})
      ...(1)> |> TodoList.update_entry(%{date: ~D[2021-12-19], id: 1, title: "Shopping"})
      %TodoList{auto_id: 3, entries: %{
        1 => %{date: ~D[2021-12-19], id: 1, title: "Shopping"},
        2 => %{date: ~D[2021-12-19], id: 2, title: "vacation"}}}
  """
  @spec update_entry(TodoList.t(), any) :: list
  def update_entry(todo_list, %{} = new_entry) do
    update_entry(todo_list, new_entry.id, fn _ -> new_entry end)
  end

  @doc """
  Update Entry in todo-list by id and func.
  ## Examples
      iex> TodoList.new()
      ...(1)> |> TodoList.add_entry(%{date: ~D[2021-12-19], title: "job"})
      ...(1)> |> TodoList.add_entry(%{date: ~D[2021-12-19], title: "vacation"})
      ...(1)> |> TodoList.update_entry(1, &Map.put(&1, :title, "Shopping"))
      %TodoList{auto_id: 3, entries: %{
        1 => %{date: ~D[2021-12-19], id: 1, title: "Shopping"},
        2 => %{date: ~D[2021-12-19], id: 2, title: "vacation"}}}
  """
  @spec update_entry(TodoList.t(), number(), any) :: list
  def update_entry(todo_list, entry_id, updater_fun) do
    case Map.fetch(todo_list.entries, entry_id) do
      :error ->
        todo_list

      {:ok, old_entry} ->
        new_entry = updater_fun.(old_entry)
        new_entries = Map.put(todo_list.entries, new_entry.id, new_entry)
        %TodoList{todo_list | entries: new_entries}
    end
  end

  @doc """
  Delete entry in todo-list by id.
  ## Examples
      iex> TodoList.new()
      ...(1)> |> TodoList.add_entry(%{date: ~D[2021-12-19], title: "job"})
      ...(1)> |> TodoList.add_entry(%{date: ~D[2021-12-19], title: "vacation"})
      ...(1)> |> TodoList.delete_entry(1)
      %TodoList{auto_id: 3, entries: %{
        2 => %{date: ~D[2021-12-19], id: 2, title: "vacation"}}}
  """
  @spec delete_entry(TodoList.t(), number()) :: list
  def delete_entry(todo_list, entry_id) do
    %TodoList{todo_list | entries: Map.delete(todo_list.entries, entry_id)}
  end
end

defmodule TodoList.CsvImporter do
  @moduledoc """
  Modul for create Todo list from csv file
  """

  @doc """
  Create new todo list from csv file.
  """
  @spec import(String.t()) :: list
  def import(file_name) do
    file_name
    |> read_lines
    |> create_entries
    |> TodoList.new()
  end

  @doc false
  defp read_lines(file_name) do
    file_name
    |> File.stream!()
    |> Stream.map(&String.replace(&1, "\n", ""))
  end

  @doc false
  defp create_entries(lines) do
    lines
    |> Stream.map(&extract_fields/1)
    |> Stream.map(&create_entry/1)
  end

  @doc false
  defp extract_fields(line) do
    line
    |> String.split(",")
    |> convert_date
  end

  @doc false
  defp convert_date([date_string, title]) do
    {parse_date(date_string), title}
  end

  @doc false
  defp parse_date(date_string) do
    [year, month, day] =
      date_string
      |> String.split("/")
      |> Enum.map(&String.to_integer/1)

    {:ok, date} = Date.new(year, month, day)
    date
  end

  @doc false
  defp create_entry({date, title}) do
    %{date: date, title: title}
  end
end
