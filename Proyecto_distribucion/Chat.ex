defmodule Chat do
  def insert({pos_id, msg}) do
    IO.puts(msg)
    # implementacion insert al CRTD
  end

  def delete(pos_id) do
    IO.inspect(pos_id)
    # implementacion de borrado al CRDT
  end

  # para el envio de mensajes a otros nodos enviar algo del tipo
  #{:os.system_time(), <mesnaje a enviar>}
  # y para enviar el pos_id de un borrado solo enviar el tiempo en milisegundos
  # de un insert

  # mas codigo ...

  def print_all_messages() do
  end

  def print_actual() do
  end


end
