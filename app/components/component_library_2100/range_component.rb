module ComponentLibrary2100
  # <%= render RangeComponent.new(name: "volume", value: 40, min: 0, max: 100, step: 5, label: "Volume") %>
  #
  # Bootstrap's form-range: a styled `<input type="range">`. HTML attributes go on the input, so
  # `class:`, `data:` and `aria:` pass through. `label:` renders a `<label>` above and `hint:` a line
  # below, wired with `aria-describedby`; without either you get the bare input. The thumb grows on a
  # touch screen (`pointer-coarse:`) so it stays easy to drag.
  class RangeComponent < BaseComponent
    INPUT = "w-full h-6 cursor-pointer appearance-none bg-transparent disabled:opacity-50 disabled:cursor-default " \
            "focus-visible:outline-none " \
            "[&::-webkit-slider-runnable-track]:h-1 [&::-webkit-slider-runnable-track]:rounded-full [&::-webkit-slider-runnable-track]:bg-surface-muted " \
            "[&::-webkit-slider-thumb]:appearance-none [&::-webkit-slider-thumb]:-mt-1.5 [&::-webkit-slider-thumb]:size-4 " \
            "[&::-webkit-slider-thumb]:rounded-full [&::-webkit-slider-thumb]:bg-primary [&::-webkit-slider-thumb]:border-0 " \
            "[&::-moz-range-track]:h-1 [&::-moz-range-track]:rounded-full [&::-moz-range-track]:bg-surface-muted " \
            "[&::-moz-range-thumb]:size-4 [&::-moz-range-thumb]:appearance-none [&::-moz-range-thumb]:rounded-full " \
            "[&::-moz-range-thumb]:border-0 [&::-moz-range-thumb]:bg-primary " \
            "focus-visible:[&::-webkit-slider-thumb]:ring-4 focus-visible:[&::-webkit-slider-thumb]:ring-primary/25 " \
            "focus-visible:[&::-moz-range-thumb]:ring-4 focus-visible:[&::-moz-range-thumb]:ring-primary/25 " \
            "pointer-coarse:[&::-webkit-slider-thumb]:size-6 pointer-coarse:[&::-moz-range-thumb]:size-6"

    def initialize(name: nil, value: nil, min: 0, max: 100, step: 1, id: nil, label: nil, hint: nil, disabled: false, **html_options)
      super(**html_options)
      @name = name
      @value = value
      @min = min
      @max = max
      @step = step
      @id = id || generated_id("range")
      @label = label
      @hint = hint
      @disabled = disabled
    end

    def call
      return input if @label.nil? && @hint.nil?

      tag.div(safe_join([label, input, hint].compact))
    end

    private

    def input
      tag.input(**attrs(INPUT, type: "range", name: @name, value: @value, min: @min, max: @max, step: @step,
        id: @id, disabled: @disabled, aria: {describedby: describedby}.compact))
    end

    def label
      tag.label(@label, for: @id, class: FormFieldComponent::LABEL) if @label
    end

    def hint
      tag.div(@hint, id: "#{@id}-hint", class: FormFieldComponent::HINT) if @hint
    end

    def describedby
      "#{@id}-hint" if @hint
    end
  end
end
