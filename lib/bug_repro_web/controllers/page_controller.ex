defmodule BugReproWeb.PageController do
  use BugReproWeb, :controller

  def home(conn, _params) do
    render(conn, :home)
  end
end
