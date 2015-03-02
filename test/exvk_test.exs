defmodule ExvkTest do
  use ExUnit.Case

  test "users" do
    assert Exvk.Users.get([1003,234424]) |> is_list
  end

  test "friends" do
  	assert Exvk.Friends.get(1003) |> is_list
  end

  test "groups" do
  	assert (Exvk.Groups.getMembers(11632794) |> length) > 13000
  end

end
