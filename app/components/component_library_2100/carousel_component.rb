module ComponentLibrary2100
  # Bootstrap's carousel: a slideshow of content with optional controls, indicators, captions and
  # autoplay.
  #
  # <%= render CarouselComponent.new(label: "Highlights", ride: true) do |carousel| %>
  #   <% carousel.with_slide(active: true, caption_title: "First") do %>
  #     <%= image_tag "one.jpg", class: "block w-full" %>
  #   <% end %>
  #   <% carousel.with_slide { image_tag "two.jpg", class: "block w-full" } %>
  # <% end %>
  #
  # Driven by the `cl-carousel` Stimulus controller: arrow controls, indicator dots, keyboard
  # (arrow keys), swipe, autoplay with pause-on-hover and pause-when-tab-hidden. `ride: true` starts
  # autoplay on load; `interval:` (ms) is the default per slide, overridable with each slide's
  # `interval:`. `wrap:` cycles past the ends (default true). `crossfade: true` fades instead of
  # sliding. `controls:`/`indicators:` default true. Set `label:` to name the region for screen
  # readers. Follows the WAI-ARIA carousel pattern; honours `prefers-reduced-motion`.
  class CarouselComponent < BaseComponent
    VIEWPORT = "relative w-full overflow-hidden"
    SLIDE = "absolute inset-0 transition-opacity duration-500 ease-in-out motion-reduce:transition-none " \
            "opacity-0 data-active:opacity-100 data-active:relative"
    CAPTION = "absolute inset-x-[15%] bottom-5 py-3 text-center text-light drop-shadow"
    CONTROL = "absolute top-0 bottom-0 z-10 flex items-center justify-center w-[15%] text-light bg-transparent border-0 " \
              "cursor-pointer opacity-70 hover:opacity-100 transition-opacity focus-visible:outline-none " \
              "focus-visible:ring-4 focus-visible:ring-light/50 disabled:opacity-25 disabled:cursor-default"
    INDICATORS = "absolute inset-x-0 bottom-3 z-10 flex justify-center gap-2"
    INDICATOR = "h-1 w-8 cursor-pointer border-0 bg-light/50 transition-opacity hover:opacity-100 " \
                "aria-[current]:bg-light focus-visible:outline-none focus-visible:ring-4 focus-visible:ring-light/50"

    renders_many :slides, "ComponentLibrary2100::CarouselSlideComponent"

    def initialize(interval: 5000, controls: true, indicators: true, crossfade: false, ride: false, wrap: true,
      keyboard: true, pause: :hover, touch: true, label: "Carousel", **html_options)
      super(**html_options)
      @interval = interval
      @controls = controls
      @indicators = indicators
      @crossfade = crossfade
      @ride = ride
      @wrap = wrap
      @keyboard = keyboard
      @pause = pause
      @touch = touch
      @label = label
    end

    def before_render
      slides.first&.activate! unless slides.any?(&:active?)
      slides.each_with_index { |slide, i| slide.position!(i, slides.size) }
    end

    def call
      tag.div(safe_join([viewport, (indicators_bar if @indicators), *(@controls ? controls : [])].compact),
        **attrs("relative", role: "group", aria: {roledescription: "carousel", label: @label},
          data: carousel_data))
    end

    private

    def carousel_data
      {
        controller: "cl-carousel",
        action: "keydown->cl-carousel#keydown mouseenter->cl-carousel#pause mouseleave->cl-carousel#resume",
        cl_carousel_interval_value: @interval,
        cl_carousel_wrap_value: @wrap,
        cl_carousel_keyboard_value: @keyboard,
        cl_carousel_pause_value: @pause.to_s,
        cl_carousel_ride_value: @ride,
        cl_carousel_touch_value: @touch,
        cl_carousel_crossfade_value: @crossfade
      }
    end

    def viewport
      tag.div(safe_join(slides), class: VIEWPORT, tabindex: 0,
        aria: {live: (@ride ? "off" : "polite")})
    end

    def indicators_bar
      buttons = slides.each_with_index.map do |slide, i|
        tag.button(tag.span(slide.indicator_label, class: "sr-only"), type: "button", class: INDICATOR,
          aria: {current: ("true" if slide.active?)}.compact,
          data: {cl_carousel_target: "indicator", action: "cl-carousel#to", index: i})
      end
      tag.div(safe_join(buttons), class: INDICATORS)
    end

    def controls
      [
        tag.button(control_icon(:prev), type: "button", class: "#{CONTROL} left-0",
          aria: {label: "Previous"}, data: {cl_carousel_target: "prev", action: "cl-carousel#prev"}),
        tag.button(control_icon(:next), type: "button", class: "#{CONTROL} right-0",
          aria: {label: "Next"}, data: {cl_carousel_target: "next", action: "cl-carousel#next"})
      ]
    end

    def control_icon(direction)
      path = (direction == :prev) ? "M15 18l-6-6 6-6" : "M9 18l6-6-6-6"
      tag.svg(tag.path(nil, d: path), class: "size-8", viewBox: "0 0 24 24", fill: "none",
        stroke: "currentColor", "stroke-width": "2", "stroke-linecap": "round", "stroke-linejoin": "round",
        aria: {hidden: "true"})
    end
  end
end
