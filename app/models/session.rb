class Session < ActiveRecord::Base
  self.table_name = 'wt_session'
  self.primary_key = 'session_id'
  belongs_to :user


end
