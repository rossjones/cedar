defmodule MatcherTest do
  use ExUnit.Case

  @fb "foo/bar.behaviour"
  @empty %{}
  @full %{ "diagnosis" =>  [ %{ "name" => "CAP" }, %{ "name" => "GORD" } ] }
  @full_cured %{ "diagnosis" =>  [ %{ "name" => "CURED" } ] }
  @intersection %{ "allergies" =>  [ %{ "name" => "latex" }, %{ "name" => "paracetamol"} ],
                   "drugs" => [ %{"name" => "morphene"}, %{"name" => "paracetamol"}]}
  @null_intersection %{ "allergies" =>  [ %{ "name" => "latex" }],
                        "drugs" => [ %{"name" => "morphene"}, %{"name" => "paracetamol"}]}
  @_ :action


  test "Match on global behaviour" do
    success = Cedar.Matcher.process_block("behaviours/global/sample.behaviour", @_, {@empty, @full})
    assert(success == true)
  end

  test "Match non-existent behaviour" do
    success = Cedar.Matcher.process_block("nosuch.behaviour", @_, {@empty, @full})
    assert(success == false)
  end

  test "basic match for is" do
    pre = %{}
    post = %{ "key" => "friday"}

    {ok, _} = Cedar.Matcher.process_line(@fb, ~s(when "key" is "friday"), {@_, pre, post})
    assert(ok == :ok)

    {ok, _} = Cedar.Matcher.process_line(@fb, ~s(when "key" is "wednesday"), {@_, pre, post})
    assert(ok == :fail)
  end

  test "basic match for is not" do
    {ok, _} = Cedar.Matcher.process_line @fb, ~s(When "diagnosis.name" is not "healthy"), {@_, @empty, @full}
    assert ok == :ok

    {ok, _} = Cedar.Matcher.process_line @fb, ~s(When "diagnosis.name" is not "CAP"), {@_, @empty, @full}
    assert ok == :fail
  end

  test "basic match for was" do
    pre = %{ "key" => "friday"}
    post = %{}

    {ok, _} = Cedar.Matcher.process_line(@fb, ~s(when "key" was "friday"), {@_, pre, post})
    assert(ok == :ok)

    {ok, _} = Cedar.Matcher.process_line(@fb, ~s(when "key" was "wednesday"), {@_, pre, post})
    assert(ok == :fail)
  end

  test "basic match for was not" do
    {ok, _} = Cedar.Matcher.process_line @fb, ~s(When "diagnosis.name" was not "healthy"), {@_, @full, @empty}
    assert ok == :ok

    {ok, _} = Cedar.Matcher.process_line @fb, ~s(When "diagnosis.name" was not "CAP"), {@_, @full, @empty}
    assert ok == :fail
  end

  test "basic match for is/was case of atom" do
    pre = %{ "key"=> "friday"}
    post = %{ "key"=> "friday"}

    {ok, _} = Cedar.Matcher.process_line(@fb, ~s(When "key" was "friday"), {@_, pre, post})
    assert(ok == :ok)

    {ok, _} = Cedar.Matcher.process_line(@fb, ~s(When "key" was "wednesday"), {@_, pre, post})
    assert(ok == :fail)
  end

  test "basic match for did contain" do
    {ok, _} = Cedar.Matcher.process_line @fb, ~s(When "diagnosis.name" did contain "ord"), {@_, @full, @empty}
    assert ok == :ok

    {ok, _} = Cedar.Matcher.process_line @fb, ~s(When "diagnosis.name" did contain "death"), {@_, @full, @empty}
    assert ok == :fail
  end

  test "basic match for contains" do
    {ok, _} = Cedar.Matcher.process_line @fb, ~s(When "diagnosis.name" contains "ord"), {@_, @empty, @full}
    assert ok == :ok

    {ok, _} = Cedar.Matcher.process_line @fb, ~s(When "diagnosis.name" contains "death"), {@_, @empty, @full}
    assert ok == :fail
  end

  test "basic match for did not contain" do
    {ok, _} = Cedar.Matcher.process_line @fb, ~s(When "diagnosis.name" did not contain "death"), {@_, @full, @empty}
    assert ok == :ok

    {ok, _} = Cedar.Matcher.process_line @fb, ~s(When "diagnosis.name" did not contain "ord"), {@_, @full, @empty}
    assert ok == :fail
  end


  test "basic match for does not contain" do
    {ok, _} = Cedar.Matcher.process_line @fb, ~s(When "diagnosis.name" does not contain "death"), {@_, @empty, @full}
    assert ok == :ok

    {ok, _} = Cedar.Matcher.process_line @fb, ~s(When "diagnosis.name" does not contain "ord"), {@_, @empty, @full}
    assert ok == :fail
  end

  test "basic match for changed to" do
    {ok, _} = Cedar.Matcher.process_line @fb, ~s(When "diagnosis.name" changed to "CAP"), {@_, @empty, @full}
    assert ok == :ok

    {ok, _} = Cedar.Matcher.process_line @fb, ~s(When "diagnosis.name" changed to "healthy"), {@_, @empty, @full}
    assert ok == :fail
  end

  test "basic match for changed from " do
    {ok, _} = Cedar.Matcher.process_line @fb, ~s(When "diagnosis.name" changed from "CAP"), {@_, @full, @empty}
    assert ok == :ok

    {ok, _} = Cedar.Matcher.process_line @fb, ~s(When "diagnosis.name" changed from "UNKNOWN"), {@_, @full, @empty}
    assert ok == :fail
  end

  test "basic match for changed from something to something else" do
    {ok, _} = Cedar.Matcher.process_line @fb, ~s(When "diagnosis.name" changed from "CAP" to "CURED"), {@_, @full, @full_cured}
    assert ok == :ok

    {ok, _} = Cedar.Matcher.process_line @fb, ~s(When "diagnosis.name" changed from "CAP" to "CAP"), {@_, @full, @empty}
    assert ok == :fail
  end

  test "basic match for admitted to" do
    ward8 = %{ "location" => [ %{ "ward" => "Ward 8"} ] }

    {ok, _} = Cedar.Matcher.process_line @fb, ~s(When admitted to "Ward 8"), {:admit, @empty, ward8}
    assert ok == :ok

    {ok, _} = Cedar.Matcher.process_line @fb, ~s(When admitted to "Ward 10"), {:admit, @empty, ward8}
    assert ok == :fail
  end

  test "invalid sentence sneaking through" do
    {ok, _} = Cedar.Matcher.process_line @fb, "When admitted to Ward 8", {:admit, @empty, %{}}
    assert ok == :fail
  end

  test "intersection of two lists has > 1 members" do
    {ok, _} = Cedar.Matcher.process_line @fb, ~s(When "allergies.name" intersects "drugs.name"), {@_, @empty, @intersection}
    assert ok == :ok

    {ok, _} = Cedar.Matcher.process_line @fb, ~s(When "allergies.name" intersects "drugs.name"), {@_, @empty, @null_intersection}
    assert ok == :fail
  end

  test "is rule is valid" do
    assert Cedar.Matcher.can_evaluate?("When \"X\" is \"Y\"")
  end

  test "made up rule is invalid" do
    assert not Cedar.Matcher.can_evaluate?(~s(When "X" likes "Y"))
  end

  test "rule with extra spaces is still valid" do
    assert Cedar.Matcher.can_evaluate?("When   \"X\"      is \"Y\"")
  end

end
