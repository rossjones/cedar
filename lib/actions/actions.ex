defmodule Cedar.Actions do

    @moduledoc """
    The functions defined in this module are intended to be 'step'-style
    matches so that the then() function of Cedar.Matcher.Step can apply
    against this module.
    """


    @doc """
    Return the {patient_id, episode_id} for this episode
    """
    defp episode_details(episode) do
      demographics = hd(episode["demographics"])
      patient_id = "#{demographics["patient_id"]}"
      { patient_id, "#{episode["id"]}" }
    end

    @doc """
    Look in the templates directory for BEHAVIOUR for a template
    matching FILENAME.

    Return the first one that matches.
    """
    defp template(behaviour, filename) do
        [_, dir, _] = Regex.split ~r/\//, behaviour
        template = Path.join ["behaviours", dir, "templates"]
        hd(Path.wildcard "#{template}/#{filename}*")
    end

    def email(behaviour, [recipient, :with, content], {action, pre, post}) do
        IO.puts "email action"
        contents = EEx.eval_file template(behaviour, content), [pre: pre, post: post]
        Cedar.Actions.Email.send recipient, "Auto Email from CEDAR", contents
    end

    def broadcast(behaviour, [msg], {action, pre, post}) do
        IO.puts "broadcast action"

        {:ok, "Sent"}
    end

    def return(behaviour, [msg], {action, pre, post}) do
        IO.puts "return action"
        contents = EEx.eval_file template(behaviour, msg), [pre: pre, post: post]
    end

    def sms(behaviour, [msg, :to, number], {action, pre, post}) do
        IO.puts "sms action"

        {:ok, "Sent"}
    end

    def refer(behaviour, [:to, target], {action, pre, post}) do
        IO.puts "refer"

        {:ok, "Sent"}
    end

end
