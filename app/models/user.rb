class User < ActiveRecord::Base
  self.table_name = 'wt_user'
  self.primary_key = 'user_id'
  has_many :sessions, foreign_key: :user_id
end