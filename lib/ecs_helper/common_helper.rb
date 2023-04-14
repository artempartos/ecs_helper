BRANCH_TO_ENV_MAPPING = {
  master: 'production',
  main: 'production',
  qa: 'qa',
  uat: 'uat',
  staging: 'staging',
  demo: 'demo',
}

class ECSHelper::CommonHelper
  attr_accessor :helper, :branch, :version, :env

  def initialize(helper)
    @helper = helper
  end

  def branch
    @branch ||= ENV['CI_COMMIT_BRANCH'] || `git rev-parse --abbrev-ref HEAD`.strip
  end

  def version
    @version ||=
      begin
        if use_image_tag_env_prefix?
          "#{environment}-#{commit_sha}"
        else
          commit_sha
        end
      end
  end

  def environment
    @env ||= helper.options[:environment] || ENV['ENVIRONMENT'] || env_from_branch || raise(StandardError, 'Environment not detected')
  end

  def project
    ENV['PROJECT']
  end

  def application
    ENV['APPLICATION']
  end

  def region
    @region ||= ENV['AWS_REGION']
  end

  def account_id
    @account_id ||= ENV['AWS_ACCOUNT_ID'] || `aws sts get-caller-identity --query "Account" --output text`.strip
  end

  def auth_private_cmd
    @auth_private_cmd ||= Terrapin::CommandLine.new("docker login -u AWS -p $(aws ecr get-login-password --region=#{region}) #{account_id}.dkr.ecr.#{region}.amazonaws.com")
  end

  private

  def env_from_branch
    BRANCH_TO_ENV_MAPPING[branch.to_sym]
  end

  def deployable_branch?
    !env_from_branch.nil?
  end

  def commit_sha
    ENV['CI_COMMIT_SHA'] || `git rev-parse HEAD`.strip
  end

  def use_image_tag_env_prefix?
    !ENV['USE_IMAGE_TAG_ENV_PREFIX'].nil?
  end

end
