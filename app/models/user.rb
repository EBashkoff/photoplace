class User < ActiveRecord::Base

  attr_reader :settings_hash
  attr_accessor :password_confirmation

  before_save :update_password

  validates :password, confirmation: true,
            unless: Proc.new { |a| a.password.blank? }
  validates :user_name, uniqueness: true, presence: true

  self.table_name = 'wt_user'
  self.primary_key = 'user_id'
  has_many :sessions, foreign_key: :user_id
  has_many :user_settings, foreign_key: :user_id

  def self.create_password_hash(password)
    BCrypt::Password.create(password)
  end

  def self.authenticate(user_name, password)
    possible_user = User.find_by(user_name: user_name)
    return unless possible_user
    stored_password = possible_user.password
    stored_password.sub!("$2y$", "$2a$") if stored_password.start_with?("$2y$")
    return possible_user if BCrypt::Password.new(stored_password) == password
  end

  def is_admin?
    return false unless settings_hash && settings_hash["canadmin"]
    self.canadmin == "1"
  end

  def method_missing(method, *args)
    return super unless settings_hash.keys.include?(method.to_s)
    settings_hash[method.to_s]
  end

  def respond_to?(method)
    settings_hash.keys.include?(method.to_s)
  end

  def settings_hash
    @settings_hash ||= self.user_settings.pluck(:setting_name, :setting_value).to_h
  end

  private

  def update_password
    if self.valid? && self.password_confirmation
      self.password = self.class.create_password_hash(self.password)
    end
  end

end
