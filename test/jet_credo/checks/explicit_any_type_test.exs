defmodule JetCredo.Checks.NoExplicitAnyTypeTest do
  use Credo.Test.Case

  alias JetCredo.Checks.ExplicitAnyType

  test "it should NOT report expected code" do
    """
    defmodule CredoSampleModule do
    end
    """
    |> to_source_file()
    |> run_check(ExplicitAnyType)
    |> refute_issues()

    """
    defmodule CredoSampleModule do
      @typep private_type() :: String.t()
      @type public_type() :: String.t() | private_type()

      @type arg_type(t) :: t | nil

      @spec foo() :: :bar
      def foo(), do: :bar

      @callback callback_fn() :: :ok
      @macrocallback macrocallback_fn() :: :ok
    end
    """
    |> to_source_file()
    |> run_check(ExplicitAnyType)
    |> refute_issues()
  end

  test "it should NOT report expected code that calls any or term functions" do
    """
    defmodule CredoSampleModule do
      any()

      def any do
        term()
      end

      term()

      def term do
        any()
      end
    end
    """
    |> to_source_file()
    |> run_check(ExplicitAnyType)
    |> refute_issues()
  end

  test "it should report code that uses any in @type" do
    """
    defmodule CredoSampleModule do
      @type any_type() :: any()
    end
    """
    |> to_source_file()
    |> run_check(ExplicitAnyType)
    |> assert_issue()

    """
    defmodule CredoSampleModule do
      @type term_type() :: term()
    end
    """
    |> to_source_file()
    |> run_check(ExplicitAnyType)
    |> assert_issue()
  end

  test "it should report code that uses any in @typep" do
    """
    defmodule CredoSampleModule do
      @type public_type() :: any_type() 
      @typep any_type() :: any()
    end
    """
    |> to_source_file()
    |> run_check(ExplicitAnyType)
    |> assert_issue()

    """
    defmodule CredoSampleModule do
      @type public_type() :: term_type()
      @typep term_type() :: term()
    end
    """
    |> to_source_file()
    |> run_check(ExplicitAnyType)
    |> assert_issue()
  end

  test "it should report code that uses any in @spec" do
    """
    defmodule CredoSampleModule do
      @spec any_fun() :: any()
      def any_fun(), do: :ok
    end
    """
    |> to_source_file()
    |> run_check(ExplicitAnyType)
    |> assert_issue()

    """
    defmodule CredoSampleModule do
      @spec term_fun() :: term()
      def term_fun(), do: :ok
    end
    """
    |> to_source_file()
    |> run_check(ExplicitAnyType)
    |> assert_issue()
  end

  test "it should report code that uses any in @callback" do
    """
    defmodule CredoSampleModule do
      @callback any_callback() :: any()
    end
    """
    |> to_source_file()
    |> run_check(ExplicitAnyType)
    |> assert_issue()

    """
    defmodule CredoSampleModule do
      @callback term_callback() :: any()
    end
    """
    |> to_source_file()
    |> run_check(ExplicitAnyType)
    |> assert_issue()
  end

  test "it should report code that uses any in @macrocallback" do
    """
    defmodule CredoSampleModule do
      @macrocallback any_callback() :: any()
    end
    """
    |> to_source_file()
    |> run_check(ExplicitAnyType)
    |> assert_issue()

    """
    defmodule CredoSampleModule do
      @macrocallback term_callback() :: any()
    end
    """
    |> to_source_file()
    |> run_check(ExplicitAnyType)
    |> assert_issue()
  end

  test "it should report code" do
    """
    defmodule CredoSampleModule do
      @type any_type() :: any() | private_any_type()
      @type term_type() :: term() | private_term_type()

      @spec term_fun() :: term()
      def term_fun(), do: :ok

      @spec any_fun() :: any()
      def any_fun(), do: :ok

      @typep private_any_type() :: any()
      @typep private_term_type() :: term()

      @macrocallback any_callback() :: any()
      @macrocallback term_callback() :: any()
    end
    """
    |> to_source_file()
    |> run_check(ExplicitAnyType)
    |> assert_issues(fn issues -> assert Enum.count(issues) == 8 end)
  end
end
