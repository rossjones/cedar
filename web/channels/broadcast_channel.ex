defmodule Cedar.BroadcastChannel do
  use Phoenix.Channel


 def join("broadcast", _message, socket) do
    {:ok, socket}
  end

  def leave(_reason, socket) do
    {:ok, socket}
  end

end