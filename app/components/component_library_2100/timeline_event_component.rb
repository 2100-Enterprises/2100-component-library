module ComponentLibrary2100
  # One event of a TimelineComponent: a self-contained <li> with its marker, connector line and text.
  #
  #   <% timeline.with_event(time: Time.current, title: "Proposal sent", variant: :success) { "Sent to Dana." } %>
  #
  # Use it through `timeline.with_event`, or render it alone, for example as the partial of a
  # `turbo_stream.prepend "activity"` (see TimelineComponent). `time:` (Time, Date or DateTime)
  # renders a <time datetime="..."> in a readable default format; `time_label:` replaces the text.
  # `title:` is the visible headline, and the body is the block. `variant:` tints the marker only:
  # the title or text must say what happened, because colour alone isn't a message. `icon:` is a
  # short string (a glyph or an initial) for the marker; pass `with_icon { ... }` for markup such
  # as an SVG. Markers are aria-hidden. The connector hides itself on the last event and the
  # alternate layout follows the list's `data-alternate`, both through CSS, so the same <li>
  # works wherever it lands in the list.
  class TimelineEventComponent < BaseComponent
    renders_one :icon

    EVENT = "group/event flex gap-4 md:group-data-alternate/timeline:grid md:group-data-alternate/timeline:grid-cols-[1fr_auto_1fr]"
    MARKER_COLUMN = "flex flex-col items-center md:group-data-alternate/timeline:col-start-2 md:group-data-alternate/timeline:row-start-1"
    MARKER = "flex shrink-0 items-center justify-center rounded-full border text-sm font-medium"
    MARKER_DOT = "size-4 mt-1"
    MARKER_ICON = "size-8"
    MARKER_PLAIN = "bg-surface border-border text-body"
    CONNECTOR = "w-0.5 flex-1 bg-border group-last/event:hidden"
    BODY = "min-w-0 flex-1 pb-8 group-last/event:pb-0 " \
           "md:group-data-alternate/timeline:col-start-3 md:group-data-alternate/timeline:row-start-1 " \
           "md:group-data-alternate/timeline:group-even/event:col-start-1 md:group-data-alternate/timeline:group-even/event:text-right"
    TIME = "block text-sm text-secondary"
    TITLE = "m-0 font-medium text-body"
    TEXT = "text-body"

    DATE_FORMAT = "%b %-d, %Y".freeze
    TIME_FORMAT = "%b %-d, %Y, %-l:%M %p".freeze

    def initialize(time: nil, title: nil, variant: nil, icon: nil, time_label: nil, **html_options)
      super(**html_options)
      @time = time
      @title = title
      @variant = variant
      @icon_text = icon
      @time_label = time_label
    end

    def call
      tag.li(safe_join([marker_column, body]), **attrs(EVENT))
    end

    private

    def marker_column
      tag.div(safe_join([marker, tag.div(class: CONNECTOR)]), class: MARKER_COLUMN)
    end

    def marker
      glyph = icon? ? icon : @icon_text
      size = glyph.present? ? MARKER_ICON : MARKER_DOT
      tint = @variant ? Variants.fetch(Variants::FILL, @variant) : MARKER_PLAIN
      tag.span(glyph, class: ComponentLibrary2100.merge_classes(MARKER, size, tint), aria: {hidden: true})
    end

    def body
      tag.div(safe_join([time_tag, title_tag, text].compact), class: BODY)
    end

    def time_tag
      return unless @time

      tag.time(@time_label || formatted_time, datetime: @time.iso8601, class: TIME)
    end

    def formatted_time
      @time.respond_to?(:hour) ? @time.strftime(TIME_FORMAT) : @time.strftime(DATE_FORMAT)
    end

    def title_tag
      tag.p(@title, class: TITLE) if @title
    end

    def text
      tag.div(content, class: TEXT) if content.present?
    end
  end
end
