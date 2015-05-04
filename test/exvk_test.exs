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

  test "users_proxy" do
    assert Exvk.Users.get([1003,234424], "768bcbf79fa114b5ee746f63a51119689ecd7a334524103e098e5fd9ec9d161cd774b81300b1ffdce7f7a", "62.205.162.68:3128") |> IO.inspect |> is_list
    assert Exvk.Users.search(%{q: "Уася"}, "768bcbf79fa114b5ee746f63a51119689ecd7a334524103e098e5fd9ec9d161cd774b81300b1ffdce7f7a", "62.205.162.68:3128") |> IO.inspect |> is_list
  end

  test "friends_proxy" do
  	assert Exvk.Friends.get(1003, "768bcbf79fa114b5ee746f63a51119689ecd7a334524103e098e5fd9ec9d161cd774b81300b1ffdce7f7a", "62.205.162.68:3128") |> IO.inspect |> is_list
  end

  test "groups_proxy" do
  	assert (Exvk.Groups.getMembers(11632794, "768bcbf79fa114b5ee746f63a51119689ecd7a334524103e098e5fd9ec9d161cd774b81300b1ffdce7f7a", "62.205.162.68:3128") |> IO.inspect |> length) > 13000
  	assert Exvk.Groups.get(1003, "768bcbf79fa114b5ee746f63a51119689ecd7a334524103e098e5fd9ec9d161cd774b81300b1ffdce7f7a", "62.205.162.68:3128") |> IO.inspect |> is_list
  end

end
