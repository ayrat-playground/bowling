defmodule Bowling.Scoring.Validation do
  def execute(frames, frame_number, value) do
    case validate_frame(frames, frame_number, value) do
      :ok -> :ok
      {:error, :not_found} -> {:error, :not_found}
      {:error, :invalid_frame} -> {:error, :invalid_frame}
    end
  end

  def previous_frame_complete?(nil), do: true

  def previous_frame_complete?(last_frame) do
    first_throw = Enum.at(last_frame.throws, 0)
    throw_count = Enum.count(last_frame.throws)

    (throw_count == 1 && first_throw.value == 10) || throw_count == 2
  end

  defp validate_frame([], 1, _value), do: :ok

  defp validate_frame([], _, _value), do: {:error, :invalid_frame}

  defp validate_frame(frames, frame_number, value) do
    last_frame = List.last(frames)

    cond do
      last_frame.number == frame_number &&
          eligible_for_current_frame?(last_frame, frame_number, value) ->
        :ok

      last_frame.number + 1 == frame_number && previous_frame_complete?(last_frame) ->
        :ok

      true ->
        {:error, :invalid_frame}
    end
  end

  defp eligible_for_current_frame?(last_frame, frame_number, value) when frame_number == 10 do
    throw_count = Enum.count(last_frame.throws)

    cond do
      throw_count == 1 ->
        true

      throw_count == 2 ->
        cond do
          Enum.at(last_frame.throws, 0).value == 10 &&
              Enum.at(last_frame.throws, 1).value + value <= 10 ->
            true

          Enum.at(last_frame.throws, 0).value + Enum.at(last_frame.throws, 1).value == 10 ->
            true

          true ->
            false
        end

      true ->
        false
    end
  end

  defp eligible_for_current_frame?(last_frame, _frame_number, value) do
    first_throw = Enum.at(last_frame.throws, 0)

    Enum.count(last_frame.throws) == 1 && first_throw.value + value <= 10
  end
end
