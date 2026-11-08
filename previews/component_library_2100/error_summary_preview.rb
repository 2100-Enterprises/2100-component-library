module ComponentLibrary2100
  # Entries are messages or `[message, href]` pairs, which link to the field.
  # @logical_path forms
  class ErrorSummaryPreview < BasePreview
    # @param title text
    def playground(title: "Please fix the following:")
      render ErrorSummaryComponent.new(title: title, errors: ["Email can't be blank", ["Name is too short", "#user_name"]])
    end
  end
end
