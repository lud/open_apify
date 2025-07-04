defmodule Oaskit.TestWeb.Schemas.FortuneCookie do
  @moduledoc false

  require(JSV).defschema(%{
    type: :object,
    properties: %{
      category: %{enum: ~w(wisdom humor warning advice)},
      message: %{type: :string}
    },
    required: [:category, :message]
  })
end
