# Create a model without a table.
class BlankModel
  include ActiveModel::Validations
  include ActiveModel::Conversion
  extend ActiveModel::Naming
  
  def initialize(attributes = {})
    attributes.each do |name, value|
      send("#{name}=", value)
    end if attributes
  end
  
  def persisted?
    false
  end
end
