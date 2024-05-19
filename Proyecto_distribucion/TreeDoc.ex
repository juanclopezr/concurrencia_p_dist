defmodule Treedoc do
  @moduledoc """
  A basic implementation of the Treedoc data structure in Elixir.
  """

  defstruct root: %Node{id: :root, value: nil, children: []}

  defmodule Node do
    @moduledoc """
    A node in the Treedoc structure.
    """
    defstruct id: nil, value: nil, children: []

    @type t :: %Node{id: any(), value: any(), children: list(t)}
  end

  @doc """
  Inserts a character into the Treedoc at the given position.
  """
  def insert(treedoc, char, position) do
    root = treedoc.root
    {new_root, _} = insert_node(root, char, position, 0, :crypto.strong_rand_bytes(16))
    %Treedoc{root: new_root}
  end

  defp insert_node(node, char, target_position, current_position, id) do
    if current_position == target_position do
      new_node = %Node{id: id, value: char, children: node.children}
      {%Node{node | children: [new_node | node.children]}, current_position + 1}
    else
      {new_children, new_position} = 
        Enum.map_reduce(node.children, current_position, fn child, pos ->
          {new_child, new_pos} = insert_node(child, char, target_position, pos, id)
          {new_child, new_pos}
        end)
      {%Node{node | children: new_children}, new_position}
    end
  end

  @doc """
  Deletes a character from the Treedoc by its identifier.
  """
  def delete(treedoc, id) do
    root = treedoc.root
    new_root = delete_node(root, id)
    %Treedoc{root: new_root}
  end

  defp delete_node(node, id) do
    new_children = Enum.filter(node.children, fn child -> child.id != id end)
    new_children = Enum.map(new_children, &delete_node(&1, id))
    %Node{node | children: new_children}
  end

  @doc """
  Merges two Treedocs.
  """
  def merge(treedoc1, treedoc2) do
    %Treedoc{root: merge_nodes(treedoc1.root, treedoc2.root)}
  end

  defp merge_nodes(%Node{id: id1, value: value1, children: children1}, %Node{id: id2, value: value2, children: children2}) when id1 == id2 do
    merged_children = merge_children(children1, children2)
    %Node{id: id1, value: value1 || value2, children: merged_children}
  end

  defp merge_nodes(node1, node2) do
    if node1.value == nil do
      %Node{id: node2.id, value: node2.value, children: merge_children(node1.children, node2.children)}
    else
      %Node{id: node1.id, value: node1.value, children: merge_children(node1.children, node2.children)}
    end
  end

  defp merge_children(children1, children2) do
    Map.values(Map.merge(Enum.into(children1, %{}, fn %Node{id: id} = n -> {id, n} end), Enum.into(children2, %{}, fn %Node{id: id} = n -> {id, n} end), &merge_nodes/2))
  end

  @doc """
  Converts the Treedoc to a string.
  """
  def to_string(treedoc) do
    root = treedoc.root
    traverse_tree(root)
    |> Enum.join("")
  end

  defp traverse_tree(%Node{value: nil, children: children}) do
    Enum.flat_map(children, &traverse_tree/1)
  end

  defp traverse_tree(%Node{value: value, children: children}) do
    [value | Enum.flat_map(children, &traverse_tree/1)]
  end
end
