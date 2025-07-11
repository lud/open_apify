defmodule Oaskit.SpecMetaTest do
  alias JSV.Schema
  alias Oaskit.Spec.OpenAPI
  alias Oaskit.Spec.SchemaWrapper
  use ExUnit.Case, async: true

  test "meta - handling references and schema wrappers in oneOf/anyOf" do
    # * all spec schemas using a Reference should put the reference first because
    # references share common keys and only require $ref
    # * all schema wrappers should be last as they accept any data
    JSV.Helpers.Traverse.prewalk(OpenAPI.json_schema(), %{}, fn
      {:val, %{oneOf: one_of} = map}, acc ->
        if Oaskit.Spec.Reference in one_of do
          flunk("reference should be given in anyOf, got oneOf: #{inspect(one_of)}")
        end

        if Oaskit.Spec.SchemaWrapper in one_of and SchemaWrapper != List.last(one_of) do
          flunk("schema wrapper not used last in oneOf: #{inspect(one_of)}")
        end

        {map, acc}

      {:val, %{anyOf: any_of} = map}, acc ->
        if Oaskit.Spec.Reference in any_of and Oaskit.Spec.Reference != hd(any_of) do
          flunk("reference not used first in anyOf: #{inspect(any_of)}")
        end

        if Oaskit.Spec.SchemaWrapper in any_of and SchemaWrapper != List.last(any_of) do
          flunk("schema wrapper not used last in anyOf: #{inspect(any_of)}")
        end

        {map, acc}

      {:val, module}, acc when is_map_key(acc, module) ->
        {:already_seen, acc}

      {:val, module}, acc when is_atom(module) ->
        if Schema.schema_module?(module) do
          # wrap in a list to re enter the traversal in case the schema has
          # oneOf at the root
          {[Schema.from_module(module)], Map.put(acc, module, true)}
        else
          {module, acc}
        end

      t, acc ->
        {elem(t, 1), acc}
    end)
  end
end
