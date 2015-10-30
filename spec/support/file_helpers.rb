require "fileutils"

module FileHelpers
  def setup_fixtures(*pathnames)
    original_schema_root = JsonMatchers.schema_root

    JsonMatchers.schema_root = File.join(*pathnames)
    FileUtils.mkdir_p(JsonMatchers.schema_root)

    original_schema_root
  end

  def teardown_fixtures(original_schema_root)
    FileUtils.rm_rf(JsonMatchers.schema_root)
    JsonMatchers.schema_root = original_schema_root
  end

  def ensure_fixtures(*pathnames)
    original_schema_root = setup_fixtures(*pathnames)

    yield

    teardown_fixtures(original_schema_root)
  end
end
