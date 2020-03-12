RSpec::Matchers.define :match_json_schema do |schema|
  schema_directory = File.join('doc', 'json_schemas')
  schema_path = File.join(schema_directory, "#{schema}.json")
  schemer = JSONSchemer.schema(Pathname.new(schema_path))

  match do |json|
    json = JSON.parse(json)
    schemer.valid?(json)
  end

  failure_message do |json|
    json = JSON.parse(json)
    schemer.validate(json).to_a
  end
end
