class AuthenticateForm < BlankModel
  attr_accessor :user_name
  attr_accessor :password

  validates :user_name, presence: true
  validates :password, presence: true
end
