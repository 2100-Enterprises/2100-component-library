module ComponentLibrary2100
  # <%= render StatComponent.new(label: "Revenue", value: "$12,400", change: "8%", trend: :up) %>
  # <%= render StatComponent.new(label: "Costs", value: "$3,100", change: "4%", trend: :up, variant: :danger) %>
  #
  # One metric for a dashboard (an extra: not in Bootstrap): a <dl> card with the label as its
  # term and the value, change and hint as descriptions. `trend:` (`:up`, `:down` or `:flat`)
  # adds an arrow and visually hidden "Increased by"/"Decreased by" text before `change:`. The
  # change is green when up and red when down; pass `variant:` when down is good (costs, churn).
  # `card: false` drops the border and padding, for use inside your own container.
  class StatComponent < BaseComponent
    CARD = "m-0 p-4 bg-surface border border-border-translucent rounded-ui animate-fade-in animate-fade-in-motion-reduce"
    PLAIN = "m-0 animate-fade-in animate-fade-in-motion-reduce"
    LABEL = "text-sm font-medium text-secondary"
    VALUE = "m-0 mt-1 text-3xl font-semibold leading-tight text-body animate-fade-in-delayed animate-fade-in-delayed-motion-reduce"
    CHANGE = "m-0 mt-1 inline-flex items-center gap-0.5 text-sm font-medium animate-fade-in-delayed animate-fade-in-delayed-motion-reduce"
    HINT = "m-0 mt-1 text-sm text-secondary animate-fade-in-delayed animate-fade-in-delayed-motion-reduce"

    TRENDS = {
      up: {variant: :success, text: "Increased by", icon: "M8 12a.5.5 0 0 0 .5-.5V5.707l2.146 2.147a.5.5 0 0 0 .708-.708l-3-3a.5.5 0 0 0-.708 0l-3 3a.5.5 0 1 0 .708.708L7.5 5.707V11.5a.5.5 0 0 0 .5.5z"},
      down: {variant: :danger, text: "Decreased by", icon: "M8 4a.5.5 0 0 1 .5.5v5.793l2.146-2.147a.5.5 0 0 1 .708.708l-3 3a.5.5 0 0 1-.708 0l-3-3a.5.5 0 1 1 .708-.708L7.5 10.293V4.5A.5.5 0 0 1 8 4z"},
      flat: {variant: :secondary, text: "Unchanged:", icon: nil}
    }.freeze

    def initialize(label:, value:, change: nil, trend: nil, variant: nil, hint: nil, card: true, **html_options)
      super(**html_options)
      @label = label
      @value = value
      @change = change
      @trend = trend&.to_sym
      @hint = hint
      @card = card
      Variants.fetch(TRENDS, @trend, kind: "trend") if @trend
      @variant = (variant || (@trend && TRENDS.fetch(@trend)[:variant]) || :secondary).to_sym
    end

    def call
      parts = [
        tag.dt(@label, class: LABEL),
        tag.dd(@value, class: VALUE),
        change_tag,
        (tag.dd(@hint, class: HINT) if @hint),
        content.presence && tag.dd(content, class: HINT)
      ]

      tag.dl(safe_join(parts.compact), **attrs(@card ? CARD : PLAIN))
    end

    private

    def change_tag
      return unless @change:

      trend = TRENDS[@trend]
      sr = tag.span("#{trend[:text]} ", class: "sr-only") if trend
      tag.dd(safe_join([icon(trend), sr, @change].compact), class: [CHANGE, Variants.fetch(Variants::TEXT, @variant)])
    end

    def icon(trend)
      return unless trend && trend[:icon]:

      tag.svg(tag.path(d: trend[:icon], "fill-rule": "evenodd"), viewBox: "0 0 16 16", fill: "currentColor",
        class: "size-4 shrink-0", aria: {hidden: true})
    end
  end
end
