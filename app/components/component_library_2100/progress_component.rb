module ComponentLibrary2100
  # <%= render ProgressComponent.new(value: 40, variant: :success, striped: true, label: true) %>
  #
  # `class:` and other attributes go on the track, so `class: "h-1"` makes a thin bar.
  # `label: true` shows the percentage; a string shows that text.
  class ProgressComponent < BaseComponent
    TRACK = "flex h-4 overflow-hidden text-[.75rem] bg-[#e9ecef] rounded-ui"
    BAR = "flex flex-col justify-center overflow-hidden text-center whitespace-nowrap text-white transition-[width] duration-[600ms] motion-reduce:transition-none"
    STRIPED = "bg-[length:1rem_1rem] " \
              "bg-[linear-gradient(45deg,rgba(255,255,255,.15)_25%,transparent_25%,transparent_50%,rgba(255,255,255,.15)_50%,rgba(255,255,255,.15)_75%,transparent_75%,transparent)]"
    ANIMATED = "animate-progress-stripes motion-reduce:animate-none"

    def initialize(value:, min: 0, max: 100, variant: :primary, striped: false, animated: false, label: nil, **html_options)
      super(**html_options)
      @value = value
      @min = min
      @max = max
      @variant = variant
      @striped = striped || animated
      @animated = animated
      @label = label
    end

    def call
      tag.div(bar, **attrs(TRACK))
    end

    private

    def bar
      tag.div(label_text, class: ComponentLibrary2100.merge_classes(bar_classes), role: "progressbar", style: "width: #{percent}%",
        aria: {valuenow: @value, valuemin: @min, valuemax: @max})
    end

    def bar_classes
      [BAR, Variants.fetch(Variants::BG, @variant), (STRIPED if @striped), (ANIMATED if @animated)]
    end

    def percent
      return 0 if @max == @min

      ((@value - @min).to_f / (@max - @min) * 100).clamp(0, 100).round(2)
    end

    def label_text
      @label == true ? "#{percent.to_i}%" : @label
    end
  end
end
