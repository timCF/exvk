defmodule ExvkTest do
  use ExUnit.Case

  test "users" do
    assert Exvk.Users.get([1003,234424]) |> IO.inspect |> is_list
    assert :error == Exvk.Users.search(%{q: "Уася"}) |> elem(0) # need token here!!!
  end

  test "friends" do
  	assert Exvk.Friends.get(1003) |> IO.inspect |> is_list
  end

  test "groups" do
  	assert (Exvk.Groups.getMembers(11632794) |> IO.inspect |> length) > 13000
  	assert :error == Exvk.Groups.get(1003) |> IO.inspect |> elem(0) # need token here!!!
  end

end
