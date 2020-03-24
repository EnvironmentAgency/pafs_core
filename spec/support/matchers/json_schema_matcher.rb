# frozen_string_literal: true

RSpec::Matchers.define :match_json_schema do |schema|
  match do |json|
    schema_directory = File.join("doc", "json_schemas")
    schema_path = File.join(schema_directory, "#{schema}.json")
    JSON::Validator.validate!(schema_path, json, strict: true)
  end
end
