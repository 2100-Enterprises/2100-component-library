module ComponentLibrary2100
  # <%= render ModalComponent.new(title: "Delete project?", size: :sm, centered: true) do |modal| %>
  #   <% modal.with_trigger(variant: :danger) { "Delete" } %>
  #   This can't be undone.
  #   <% modal.with_footer do %>
  #     <%= ui_button "Cancel", variant: :secondary, data: { action: "cl-dialog#close" } %>
  #     <%= ui_button "Delete", variant: :danger %>
  #   <% end %>
  # <% end %>
  #
  # Uses a native <dialog> opened with showModal(), so the page behind is inert, focus is trapped, and
  # Escape closes it. Any element inside the component with `data-action="cl-dialog#open"` opens it
  # and `cl-dialog#close` closes it. HTML attributes go on the <dialog>. The body scrolls when the
  # content is taller than the screen. `static_backdrop: true` ignores clicks outside the dialog.
  # The dialog fades and drops into place, and the backdrop fades, on open and on close, where the
  # browser supports `@starting-style`. Under prefers-reduced-motion it just appears.
  # `close:` takes CloseButtonComponent options (`close: {white: true}` on a dark dialog). A trigger with
  # `data-cl-dialog-target="trigger"` gets `aria-expanded` kept in step with the dialog; the built-in
  # trigger is one and has `aria-controls`. The title is a heading, `heading_level:` 1 to 6 (default 2;
  # the size stays the same). `description_id:` points `aria-describedby` at an element inside.
  class ModalComponent < BaseComponent
    SIZES = {sm: "max-w-[300px]", md: "max-w-[500px]", lg: "max-w-[800px]", xl: "max-w-[1140px]"}.freeze
    # The backdrop fades in and out. `display` and `overlay` transition discretely, so a closing
    # dialog stays in the top layer until its fade ends. Offcanvas shares this.
    BACKDROP = "backdrop:bg-backdrop backdrop:opacity-0 open:backdrop:opacity-100 starting:open:backdrop:opacity-0 " \
               "backdrop:transition-[opacity,display,overlay] backdrop:duration-200 backdrop:transition-discrete " \
               "motion-reduce:backdrop:transition-none"
    DIALOG = "mx-auto w-[calc(100%-1rem)] max-h-[calc(100%-3.5rem)] p-0 text-body bg-surface border border-border-translucent rounded-ui-lg " \
             "outline-none open:flex flex-col #{BACKDROP} " \
             "opacity-0 -translate-y-6 open:opacity-100 open:translate-y-0 starting:open:opacity-0 starting:open:-translate-y-6 " \
             "transition-[opacity,translate,display,overlay] duration-200 transition-discrete motion-reduce:transition-none"
    HEADER = "flex items-center justify-between gap-4 p-4 border-b border-border"
    TITLE = "m-0 text-xl font-medium leading-normal"
    BODY = "grow min-h-0 p-4 overflow-y-auto"
    FOOTER = "flex flex-wrap items-center justify-end gap-2 p-3 border-t border-border"

    HEADING_LEVELS = (1..6)

    # The heading tag for a level, so every dialog validates it the same way.
    def self.heading_tag(level)
      raise ArgumentError, "heading_level must be 1 to 6, got #{level.inspect}" unless HEADING_LEVELS.cover?(level) && level.is_a?(Integer)

      :"h#{level}"
    end

    renders_one :trigger, ->(**opts) { ButtonComponent.new(**merge_attrs(opts, nil, **trigger_defaults)) }
    renders_one :footer, ->(**opts, &block) { tag.div(**merge_attrs(opts, FOOTER), &block) }

    def initialize(title: nil, size: :md, centered: false, static_backdrop: false, close: {}, heading_level: 2, description_id: nil, **html_options)
      super(**html_options)
      @heading_tag = self.class.heading_tag(heading_level)
      @description_id = description_id
      @title = title
      @size = size
      @centered = centered
      @static_backdrop = static_backdrop
      @close = close
      @title_id = generated_id("dialog-title")
      @dialog_id = html_options[:id] || generated_id("dialog")
    end

    def call
      tag.div(safe_join([trigger, dialog]), class: "contents", data: {controller: "cl-dialog", cl_dialog_locked_value: @static_backdrop})
    end

    private

    def dialog
      options = attrs(dialog_css, id: @dialog_id, data: {cl_dialog_target: "dialog", action: "click->cl-dialog#backdrop"})
      options[:aria] = {labelledby: @title_id}.merge(options[:aria] || {}) if @title
      options[:aria] = {describedby: @description_id}.merge(options[:aria] || {}) if @description_id

      tag.dialog(safe_join([header, tag.div(content, class: BODY), footer]), **options)
    end

    def header
      return unless @title

      close = render(CloseButtonComponent.new(**merge_attrs(@close, nil, data: {action: "cl-dialog#close"})))
      tag.div(safe_join([tag.public_send(@heading_tag, @title, id: @title_id, class: TITLE), close]), class: header_css)
    end

    def dialog_css
      [DIALOG, Variants.fetch(SIZES, @size, kind: "size"), (@centered ? "my-auto" : "mt-7 mb-auto")]
    end

    def header_css = HEADER

    def trigger_defaults
      {variant: :primary, aria: {haspopup: "dialog", controls: @dialog_id, expanded: false},
       data: {action: "cl-dialog#open", cl_dialog_target: "trigger"}}
    end
  end
end
