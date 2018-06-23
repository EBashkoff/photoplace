class ActionView::Helpers::FormBuilder
  def first_error(field = nil)
    # Only display one message.
    return if @first_error_message_displayed

    # Get the first message.
    if field.present?
      message = self.object.errors[field].first
    else
      field, message = self.object.errors.first
    end

    # Nothing to do if no message.
    return if message.blank?

    # Mark that we've run.
    @first_error_message_displayed = true

    # Generate the full message.
    "<div class='text-danger'>#{self.object.errors.full_message(field, message)}</div>".html_safe
  end
end
