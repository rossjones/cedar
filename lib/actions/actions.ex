defmodule Cedar.Actions do
    import Cedar.Vars, only: [resolve_var: 1]

    @moduledoc """
    The functions defined in this module are intended to be 'step'-style
    matches so that the then() function of Cedar.Matcher.Step can apply
    against this module.
    """


    """
    Return the {patient_id, episode_id} for this episode
    """
    defp episode_details(episode) do
      demographics = hd(episode["demographics"])
      patient_id = "#{demographics["patient_id"]}"
      { patient_id, "#{episode["id"]}" }
    end

    """
    Look in the templates directory for BEHAVIOUR for a template
    matching FILENAME.

    Return the first one that matches.
    """
    defp template(behaviour, filename) do
        [_, dir, _] = Regex.split ~r/\//, behaviour
        template = Path.join ["behaviours", dir, "templates"]
        hd(Path.wildcard "#{template}/#{filename}*")
    end

    def email(behaviour, [recipient, :with, content], {_action, pre, post, _endpoint}) do
        IO.puts "email action"
        contents = EEx.eval_file template(behaviour, content), [pre: pre, post: post, episode: post]
        Cedar.Actions.Email.send resolve_var(recipient), "Auto Email from CEDAR", contents
    end

    def broadcast(_behaviour, [msg], {_action, _pre, _post, _endpoint}) do
        IO.puts "broadcast action"
        Phoenix.Channel.broadcast("broadcast", "new:event", %{"event": msg})
        {:ok, "Sent"}
    end

    def return(behaviour, [msg], {_action, pre, post, _endpoint}) do
        IO.puts "return action"
        contents = EEx.eval_file template(behaviour, msg), [pre: pre, post: post]
        contents
    end

    def sms(_behaviour, [msg, :to, number], {_action, _pre, _post, _endpoint}) do
        IO.puts "sms action"
        # TODO: Actually get a response from the deliver call
        Cedar.Actions.SMS.deliver([number], msg)
        {:ok, "Sent"}
    end

    def refer(_behaviour, [:to, target], {_action, _pre, post, endpoint}) do
        IO.puts "Referral action"
        [demographics|_] = post["demographics"]
        patient_id = demographics["patient_id"]
        Cedar.Actions.OpalReferral.refer target, post["id"], patient_id, endpoint
        {:ok, "Sent"}
    end

end

