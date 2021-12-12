defmodule TodolistTest do
  use ExUnit.Case
  doctest TodoList

  test "new todolist with initial params" do
    entries = [
      %{date: ~D[2018-12-19], title: "Dentist"},
      %{date: ~D[2018-12-20], title: "Shopping"},
      %{date: ~D[2018-12-19], title: "Movies"}
    ]
    answer = %TodoList{
      auto_id: 4,
      entries: %{
        1 => %{date: ~D[2018-12-19], id: 1, title: "Dentist"},
        2 => %{date: ~D[2018-12-20], id: 2, title: "Shopping"},
        3 => %{date: ~D[2018-12-19], id: 3, title: "Movies"}
      }
    }
    assert TodoList.new(entries) ==  answer
    assert TodoList.CsvImporter.import("todos.csv") == answer
  end


end
