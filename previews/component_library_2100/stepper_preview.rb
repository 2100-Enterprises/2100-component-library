module ComponentLibrary2100
  # @logical_path navigation
  class StepperPreview < BasePreview
    # @param current number "The current step, from 1"
    # @param breakpoint select { choices: [sm, md, lg, xl, xxl] }
    def playground(current: 3, breakpoint: :md)
      template(:playground, current: current, breakpoint: breakpoint)
    end
  end
end
