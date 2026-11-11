module ComponentLibrary2100
  # One section of an AccordionComponent. Create these through `accordion.with_item`.
  class AccordionItemComponent < BaseComponent
    BASE = "group overflow-hidden bg-surface border border-border-translucent first:rounded-t-ui last:rounded-b-ui not-first:border-t-0"
    SUMMARY = "relative flex items-center justify-between gap-4 px-5 py-4 text-base text-body cursor-pointer list-none " \
              "[&::-webkit-details-marker]:hidden group-open:bg-primary-subtle group-open:text-primary-emphasis " \
              "focus-visible:outline-none focus-visible:ring-4 focus-visible:ring-inset focus-visible:ring-primary/25"
    CHEVRON = "size-4 shrink-0 transition-transform duration-200 group-open:rotate-180 motion-reduce:transition-none"
    BODY = "px-5 py-4"
    CONTENT = "transition-opacity duration-500 ease-out group-open:opacity-100 opacity-0 group-open:transition-opacity"

    def initialize(title:, open: false, group: nil, **html_options)
      super(**html_options)
      @title = title
      @open = open
      @group = group
    end

    def call
      tag.details(safe_join([summary, tag.div(content, class: "#{BODY} #{CONTENT}")]), **attrs(BASE, name: @group, open: @open))
    end

    private

    def summary
      tag.summary(safe_join([@title, chevron]), class: SUMMARY)
    end

    def chevron
      tag.svg(
        tag.path(d: "M2 5l6 6 6-6"),
        class: CHEVRON, viewBox: "0 0 16 16", fill: "none", stroke: "currentColor",
        "stroke-width": 2, "stroke-linecap": "round", "stroke-linejoin": "round", aria: {hidden: true}
      )
    end
  end
end
