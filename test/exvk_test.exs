defmodule ExvkTest do
  use ExUnit.Case
"""
  test "users" do
    assert Exvk.Users.get([1003,234424]) |> IO.inspect |> is_list
  end

  test "friends" do
  	assert Exvk.Friends.get(1003) |> IO.inspect |> is_list
  end
"""
  test "groups" do
  	Exvk.Groups.getMembers(1233) |> IO.inspect
  	assert true
  end

end
