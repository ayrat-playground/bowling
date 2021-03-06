defmodule Bowling.Scoring.Validation do
  @moduledoc """
  Validation logic
  """

  alias Bowling.Scoring.Frame

  @error_tuple {:error, :invalid_frame}

  @doc """
  Checks if the given throw `value` can be inserted in the given frame
  for the game with the given `frames` already played.

  Returns `:ok` on success, `{:error, :invalid_frame}` otherwise.

  ## Examples

      iex> Bowling.Scoring.Validation.run([], 1, 10)
      :ok

      iex> Bowling.Scoring.Validation.run([%{number: 1, throws: [%{number: 0, value: 10}]}], 1, 10)
      {:error, :invalid_frame}

      iex> Bowling.Scoring.Validation.run([], 200, 10)
      {:error, :invalid_frame}

      iex> Bowling.Scoring.Validation.run([], 1, -200)
      {:error, :invalid_frame}
  """

  # spec run([Frame.t(), integer(), integer()]) :: :ok | {:error, :invalid_frame}
  def run(_, frame_number, _) when frame_number > 10 or frame_number < 1, do: @error_tuple

  def run(_, _, value) when value > 10 or value < 0, do: @error_tuple

  def run(frames, frame_number, value) do
    do_validate_frame(frames, frame_number, value)
  end

  @doc """
  Check is the given frame is full (it can't accept anymore throws)

  ## Examples

      iex> Bowling.Scoring.Validation.frame_complete?(nil)
      true

      iex> Bowling.Scoring.Validation.frame_complete?(%{throws: [%{value: 5, number: 0}]})
      false

      iex> Bowling.Scoring.Validation.frame_complete?(%{throws: [%{value: 5, number: 0}, %{value: 5, number: 1}]})
      true

      iex> Bowling.Scoring.Validation.frame_complete?(%{throws: [%{value: 10, number: 0}]})
      true
  """
  @spec frame_complete?(nil | Frame.t()) :: boolean
  def frame_complete?(nil), do: true

  def frame_complete?(last_frame) do
    first_throw = Enum.at(last_frame.throws, 0)
    throw_count = Enum.count(last_frame.throws)

    (throw_count == 1 && first_throw.value == 10) || throw_count == 2
  end

  @spec do_validate_frame([Frame.t()], integer(), integer()) :: :ok | {:error, :invalid_frame}
  defp do_validate_frame([], 1, _value), do: :ok

  defp do_validate_frame([], _, _value), do: @error_tuple

  defp do_validate_frame(frames, frame_number, value) do
    last_frame = List.last(frames)

    cond do
      last_frame.number == frame_number &&
          eligible_for_current_frame?(last_frame, frame_number, value) ->
        :ok

      last_frame.number + 1 == frame_number && frame_complete?(last_frame) ->
        :ok

      true ->
        @error_tuple
    end
  end

  @spec eligible_for_current_frame?(Frame.t(), integer(), integer()) :: boolean()
  defp eligible_for_current_frame?(last_frame, frame_number, value) when frame_number == 10 do
    throw_count = Enum.count(last_frame.throws)

    cond do
      throw_count == 1 ->
        true

      throw_count == 2 ->
        third_throw_valid?(last_frame, value)

      true ->
        false
    end
  end

  defp eligible_for_current_frame?(last_frame, _frame_number, value) do
    first_throw = Enum.at(last_frame.throws, 0)

    Enum.count(last_frame.throws) == 1 && first_throw.value + value <= 10
  end

  @spec third_throw_valid?(Frame.t(), integer()) :: boolean()
  defp third_throw_valid?(last_frame, value) do
    cond do
      Enum.at(last_frame.throws, 0).value == 10 &&
          Enum.at(last_frame.throws, 1).value + value <= 10 ->
        true

      Enum.at(last_frame.throws, 0).value + Enum.at(last_frame.throws, 1).value == 10 ->
        true

      true ->
        false
    end
  end
end
