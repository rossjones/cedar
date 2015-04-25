defmodule VariablesTest do
  use ExUnit.Case
  alias Cedar.VarServer, as: Vars

  test "Create a new variable " do
    Vars.create("Test var", "Test value")    
    assert Vars.lookup("Test var") == "Test value"
  end

  test "We can get all variables" do 
    assert Dict.size(Vars.all) == 1
  end 

end