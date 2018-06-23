# See https://blog.botreetechnologies.com/ruby-on-rails-discovering-amazon-cloudfront-10ec6f846474

Aws::CF::Signer.configure do |config|
  kpid = Rails.application.secrets.aws_cf_access_key_id
  config.key_path = "pk-#{kpid}-cf-private-key.pem"
  # or config.key = ENV.fetch('PRIVATE_KEY')
  config.key_pair_id = kpid
  config.default_expires = 3600
end
