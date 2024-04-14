defmodule Chat do

  def start(chat_members, chat_history) do
    spawn(__MODULE__, :chat_loop, [chat_members, chat_history])
    Process.add_user(self(), :chatroom)
    end

  defp chat_loop(chat_members, chat_history) do
    receive do
      {:add_user, user} ->
        if User.registered?(user) do
          IO.puts("User already exists")
        else
          send user, {:add_user, self()}
          chat_loop(Tuple.append(chat_members, user), chat_history)
        end

      {:delete_user, user} ->
        if User.registered?(user) do
          send user, {:delete_user, self()}
          chat_loop(Tuple.delete(chat_members, user), chat_history)
        else
          IO.puts("User does not exist")
          chat_loop(chat_members, chat_history)
        end

      {:write_message, user, message} ->
        if User.registered?(user) do
          for member <- chat_members do
            send member, {:update_messages, {user, message}}
          end
          chat_loop(chat_members, Tuple.append(chat_history, {user, message}))
        else
          IO.puts("User does not exist")
          chat_loop(chat_members, chat_history)
        end
    end
  end
end

defmodule User do
  def start(id) do
    spawn(__MODULE__, :loop, [false, []])
    Process.add_user(self(), :"user_#{id}")
  end

  def registered?(user) do
    send user, {:state, self()}
    receive do
      {:ok, state} -> state
      _ -> false
    end
  end

  def add_user(user, sender) do
    send user, {:add_user, sender}
  end

  def delete_user(user, sender) do
    send user, {:delete_user, sender}
  end

  def write_message(chatroom, user, message) do
    send chatroom, {:write_message, user, message}
  end

  def read_messages(user) do
    send user, {:read_messages}
    receive do
      messages -> messages
    end
  end

  defp loop(registered, chat_messages) do
    receive do
      {:state, sender} ->
        send sender {:ok, registered}
      {:add_user, sender} ->
        send sender, :ok
        loop(true, chat_messages)
      {:delete_user, sender} ->
        send sender, :ok
        loop(false, chat_messages)
      {:update_messages, message, sender} ->
        loop(registered, chat_messages ++ message)
      {:read_messages, sender} ->
        send sender, chat_messages
        loop(registered, chat_messages)
    end
  end

end
