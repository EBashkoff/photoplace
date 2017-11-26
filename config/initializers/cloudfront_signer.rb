# See https://blog.botreetechnologies.com/ruby-on-rails-discovering-amazon-cloudfront-10ec6f846474

Aws::CF::Signer.configure do |config|
  config.key_path = 'rsa-APKAIOSOZGD5NGO75TXA-cf-public-key.pem'
  # or config.key = ENV.fetch('PRIVATE_KEY')
  config.key_pair_id = 'APKAIOSOZGD5NGO75TXA'
  config.default_expires = 3600
end
