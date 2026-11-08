module ComponentLibrary2100
  # One slide of a CarouselComponent. Use through `carousel.with_slide`; not rendered on its own.
  #
  #   <% carousel.with_slide(active: true, caption_title: "First", caption_text: "Intro") { ... } %>
  #
  # `active:` marks the slide shown first (defaults to the first slide). `interval:` overrides the
  # carousel's autoplay interval for this slide (ms). `caption_title:`/`caption_text:` overlay a
  # caption. HTML attributes go on the slide element.
  class CarouselSlideComponent < BaseComponent
    def initialize(active: false, interval: nil, caption_title: nil, caption_text: nil, **html_options)
      super(**html_options)
      @active = active
      @interval = interval
      @caption_title = caption_title
      @caption_text = caption_text
      @index = 0
      @count = 1
    end

    def active? = @active
    def activate! = @active = true

    def position!(index, count)
      @index = index
      @count = count
    end

    def indicator_label
      "Slide #{@index + 1}"
    end

    def call
      tag.div(safe_join([content, caption].compact),
        **attrs(CarouselComponent::SLIDE, role: "group", aria: {roledescription: "slide", label: "#{@index + 1} of #{@count}"},
          data: {cl_carousel_target: "slide", active: (@active ? "" : nil), interval: @interval}.compact))
    end

    private

    def caption
      return if @caption_title.nil? && @caption_text.nil?

      tag.div(safe_join([
        (tag.h5(@caption_title, class: "text-lg font-medium") if @caption_title),
        (tag.p(@caption_text) if @caption_text)
      ].compact), class: CarouselComponent::CAPTION)
    end
  end
end
