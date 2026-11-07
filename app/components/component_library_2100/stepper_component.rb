module ComponentLibrary2100
  # <%= render StepperComponent.new(label: "Project status", current: 3) do |stepper| %>
  #   <% stepper.with_step("Draft", hint: "3 May") %>
  #   <% stepper.with_step("Proposed", href: "/projects/1/proposal") %>
  #   <% stepper.with_step("Approved") %>
  #   <% stepper.with_step("In progress") %>
  #   <% stepper.with_step("Complete") %>
  # <% end %>
  #
  # Ordered steps in an <ol> named by `label:` (an extra: not in Bootstrap). Each step is
  # :complete, :current or :upcoming: pass `state:`, or give the component `current:` (the
  # 1-based number of the current step) and steps before it are complete, after it upcoming.
  # The current step has `aria-current="step"`; complete steps end with `complete_text:`, hidden
  # visually ("(completed)" by default, `nil` for none). A step is plain text, a link (`href:`)
  # or a submit button (`name:` and `value:`, for a form that saves and moves on). `hint:` adds a
  # line under the label, tied to a link or button with `aria-describedby`. Horizontal from the
  # `md` breakpoint, stacked below it; `vertical: true` always stacks. Other step options are
  # HTML attributes for the link, button or text (`form:`, `disabled:`, `data:` ...).
  class StepperComponent < BaseComponent
    STATES = %i[complete current upcoming].freeze

    LIST = {
      responsive: "flex flex-col m-0 p-0 list-none md:flex-row",
      vertical: "flex flex-col m-0 p-0 list-none"
    }.freeze

    # The connector is the step's ::after: down from the marker when stacked, across to the next marker when horizontal.
    STEP = {
      responsive: "relative flex flex-col gap-1 pb-6 last:pb-0 " \
                  "not-last:after:absolute not-last:after:content-[''] not-last:after:left-4 not-last:after:top-9 " \
                  "not-last:after:bottom-1 not-last:after:w-0.5 not-last:after:-translate-x-1/2 not-last:after:bg-border " \
                  "data-[state=complete]:not-last:after:bg-primary " \
                  "md:flex-1 md:items-center md:pb-0 md:text-center md:not-last:after:top-4 md:not-last:after:bottom-auto " \
                  "md:not-last:after:left-[calc(50%+1.5rem)] md:not-last:after:right-[calc(-50%+1.5rem)] " \
                  "md:not-last:after:w-auto md:not-last:after:h-0.5 md:not-last:after:translate-x-0 md:not-last:after:-translate-y-1/2",
      vertical: "relative flex flex-col gap-1 pb-6 last:pb-0 " \
                "not-last:after:absolute not-last:after:content-[''] not-last:after:left-4 not-last:after:top-9 " \
                "not-last:after:bottom-1 not-last:after:w-0.5 not-last:after:-translate-x-1/2 not-last:after:bg-border " \
                "data-[state=complete]:not-last:after:bg-primary"
    }.freeze

    TARGET = {
      responsive: "group flex items-center gap-3 text-left md:flex-col md:gap-2 md:text-center",
      vertical: "group flex items-center gap-3 text-left"
    }.freeze

    HINT = {
      responsive: "pl-11 text-sm text-secondary md:pl-0",
      vertical: "pl-11 text-sm text-secondary"
    }.freeze

    # Links and buttons; plain text gets only TARGET.
    ACTION = "p-0 text-inherit no-underline bg-transparent border-0 rounded-ui cursor-pointer " \
             "focus-visible:outline-none focus-visible:ring-4 focus-visible:ring-primary/25 " \
             "disabled:cursor-default disabled:opacity-65"
    ACTION_LABEL = "group-hover:underline group-disabled:no-underline"

    MARKER = {
      complete: "inline-flex items-center justify-center shrink-0 size-8 text-sm font-medium rounded-full border-2 " \
                "bg-primary border-primary text-primary-on",
      current: "inline-flex items-center justify-center shrink-0 size-8 text-sm font-medium rounded-full border-2 " \
               "bg-transparent border-primary text-primary",
      upcoming: "inline-flex items-center justify-center shrink-0 size-8 text-sm font-medium rounded-full border-2 " \
                "bg-transparent border-border text-secondary"
    }.freeze

    LABEL = {
      complete: "text-body",
      current: "font-medium text-body",
      upcoming: "text-secondary"
    }.freeze

    CHECK = "M13.854 3.646a.5.5 0 0 1 0 .708l-7 7a.5.5 0 0 1-.708 0l-3.5-3.5a.5.5 0 1 1 .708-.708L6.5 10.293l6.646-6.647a.5.5 0 0 1 .708 0"

    renders_many :steps, ->(label = nil, state: nil, href: nil, name: nil, value: nil, hint: nil, **opts, &block) {
      @step_count += 1
      number = @step_count
      state = resolve_state(state, number)
      text = block ? capture(&block) : label
      hint_id = generated_id("step-hint") if hint && (href || name)

      tag.li(safe_join([target(number, state, text, href, name, value, hint_id, opts), hint_tag(hint, hint_id)].compact),
        class: STEP.fetch(layout), data: {state: state})
    }

    def initialize(label:, current: nil, vertical: false, complete_text: "(completed)", **html_options)
      super(**html_options)
      @label = label
      @current = current&.to_i
      @vertical = vertical
      @complete_text = complete_text
      @step_count = 0
    end

    def call
      tag.ol(safe_join(steps), **attrs(LIST.fetch(layout), aria: {label: @label}))
    end

    private

    def layout = @vertical ? :vertical : :responsive

    def resolve_state(state, number)
      return Variants.fetch(STATES.index_by(&:itself), state, kind: "state") if state
      return :upcoming unless @current

      if number < @current then :complete
      elsif number == @current then :current
      else :upcoming
      end
    end

    def target(number, state, text, href, name, value, hint_id, opts)
      inner = safe_join([marker(number, state), label_tag(text, state, interactive: href || name)])
      aria = {current: ("step" if state == :current), describedby: hint_id}.compact
      css = [TARGET.fetch(layout), (ACTION if href || name)]

      if href
        tag.a(inner, **merge_attrs(opts, css, href: href, aria: aria))
      elsif name
        tag.button(inner, **merge_attrs(opts, css, type: :submit, name: name, value: value, aria: aria))
      else
        tag.span(inner, **merge_attrs(opts, css, aria: aria))
      end
    end

    def marker(number, state)
      symbol = if state == :complete
        tag.svg(tag.path(d: CHECK), viewBox: "0 0 16 16", fill: "currentColor", class: "size-4")
      else
        number.to_s
      end
      tag.span(symbol, class: MARKER.fetch(state), aria: {hidden: true})
    end

    def label_tag(text, state, interactive:)
      done = tag.span(" #{@complete_text}", class: "sr-only") if state == :complete && @complete_text.present?
      tag.span(safe_join([text, done].compact), class: [LABEL.fetch(state), (ACTION_LABEL if interactive)])
    end

    def hint_tag(hint, hint_id)
      return unless hint

      tag.span(hint, id: hint_id, class: HINT.fetch(layout))
    end
  end
end
