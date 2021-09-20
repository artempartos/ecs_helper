# frozen_string_literal: true

require 'test_helper'

class ECSHelper::Command::ExportImagesTest < Minitest::Test
  def test_export_env_secrets_with_no_vars
    command = 'export_images'

    with_command(command) do |setup|
      repo = AwsSupport.repository("#{setup.project}-#{setup.application}-web")
      stub_repositories([repo])

      helper = ECSHelper.new
      expected_result = /^export.+WEB_IMAGE=#{repo[:repository_uri]}.*/

      assert_output(expected_result) do
        export_string = helper.run
        assert (export_string =~ expected_result)
      end
    end
  end
end
