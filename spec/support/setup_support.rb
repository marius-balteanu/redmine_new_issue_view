module SetupSupport
  private

  def create_base_setup_without_settings
    Setting.plugin_redmine_restrict_tracker = nil
  end

  def create_base_setup_with_settings
    @custom_field = create :custom_field, :user
    hash = {
      'custom_field_id' => @custom_field.id
    }
    Setting.plugin_redmine_restrict_tracker = hash
  end
end
