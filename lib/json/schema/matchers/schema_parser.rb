module JSON
  class Schema
    module Matchers
      class SchemaParser

        attr_reader :schema_path

        def initialize(schema_path)
          @schema_path = Pathname(schema_path)
        end

        def schema_for(schema_name)
          file = schema_path.join("#{schema_name}.json")

          if file.exist?
            ERB.new(file.read).result(binding)
          else
            raise MissingSchema, file.to_s
          end
        end
      end
    end
  end
end
