class UserSetting < ActiveRecord::Base
  self.table_name = 'wt_user_setting'
  self.primary_key = 'user_id'
  belongs_to :user

end
