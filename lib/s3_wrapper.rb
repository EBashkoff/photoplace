class S3Wrapper

  ASSET_EXPIRATION_TIME = 60 # minutes

  def self.aws_s3_client
    @@aws_s3_client ||= Aws::S3::Client.new
  end

  def self.signer
    @@signer ||=
      begin
        aws_cf_access_key_id = Rails.application.secrets.aws_cf_access_key_id
        private_cloudfront_key = S3Wrapper.get("pk-#{aws_cf_access_key_id}-cf-private-key.pem")
        cf_access_key_id = Rails.application.secrets.aws_cf_access_key_id
        Aws::CloudFront::UrlSigner.new(
          key_pair_id: cf_access_key_id,
          private_key: private_cloudfront_key
        )
      end
  end

  def self.put(key, item)
    item = item.to_json if item.is_a?(Hash)
    aws_s3_client.put_object(
      key:    key,
      body:   item,
      bucket: s3_bucket,
      acl:    'private'
    )
    return true
  rescue Aws::S3::Errors::ServiceError => e
    Log.exception(e, { s3_bucket: s3_bucket, key: key })
    return false
  end

  def self.get(key)
    result = aws_s3_client.get_object(key: key, bucket: s3_bucket).body.read

    begin
      return JSON.parse(result).deep_symbolize_keys
    rescue JSON::ParserError
      return result
    end

  rescue Aws::S3::Errors::NoSuchKey
    return nil

  rescue Aws::S3::Errors::ServiceError => e
    Log.exception(e, { s3_bucket: s3_bucket, key: key })
    return nil
  end

  def self.cloudfront_url(path)
    aws_s3_client
    signer.signed_url(
      "#{Rails.application.secrets.aws_cf_base_url}/#{path}",
      expires: ASSET_EXPIRATION_TIME.minutes.from_now
    )
  end

  def self.s3_bucket
    Rails.application.secrets.aws_s3_bucket
  end

end
