module ComponentLibrary2100
  # A set of checkboxes (multi-select) or radio buttons (single-select) drawn as pills or a
  # segmented control. It is the form-field counterpart of ChipComponent: the choices submit with
  # the form.
  #
  #   <%= ui_toggle_group name: "platforms", type: :checkbox, label: "Platforms", style: :pills do |group| %>
  #     <% group.with_option("Instagram", value: "instagram", checked: true, variant: :primary) %>
  #     <% group.with_option("TikTok", value: "tiktok") %>
  #     <% group.with_option(value: "grid", icon_only: true, label: "Grid view") { grid_svg } %>
  #   <% end %>
  #
  # Renders a <fieldset> whose <legend> is `label:` (required). `legend_visible: false` hides the
  # legend with sr-only but keeps it as the group's name. Each option is a <label> around a
  # visually hidden native input and a styled <span>, so keyboard and screen reader behaviour is the
  # browser's own: arrow keys for radios, space to toggle checkboxes. The checked state is a
  # coloured fill, a bold label and a check mark, so it doesn't rely on colour alone. Options
  # answer to 44px on touch screens.
  #
  # type: :checkbox (default; input names become "name[]") or :radio. style: :pills (separate
  # rounded buttons) or :segmented (joined buttons). size: :sm or :md. variant: the colour of the
  # checked state, per option or as the group's default (primary). `icon_only: true` makes the
  # block the icon and `label:` its visually hidden accessible name, which is then required.
  # `autosubmit: true` submits the surrounding form on change (see SwitchComponent).
  # `hidden: true` adds a hidden empty field first so a checkbox group with nothing checked still
  # submits. `choices:` (`[label, value]` pairs, hashes or strings) and `checked:` build options
  # without slots, as `FormBuilder#toggle_group` does. HTML attributes go on the <fieldset>.
  class ToggleGroupComponent < BaseComponent
    FIELDSET = "m-0 p-0 border-0 min-w-0"
    LEGEND = "mb-2 p-0"
    LIST = {pills: "flex flex-wrap gap-2", segmented: "inline-flex max-w-full"}.freeze
    LABEL = {pills: "inline-flex cursor-pointer select-none has-disabled:cursor-default", segmented: "inline-flex cursor-pointer select-none -ms-px first:ms-0 has-disabled:cursor-default"}.freeze
    FIRST = "rounded-s-ui"
    LAST = "rounded-e-ui"
    INPUT = "peer sr-only"
    FACE = "inline-flex items-center justify-center gap-1.5 border border-border bg-surface text-body leading-tight " \
           "pointer-coarse:min-h-11 pointer-coarse:min-w-11 transition duration-150 hover:border-primary-border " \
           "peer-checked:font-semibold peer-checked:z-10 peer-focus-visible:ring-4 peer-focus-visible:ring-primary/25 " \
           "peer-focus-visible:z-20 relative peer-disabled:opacity-50 peer-disabled:hover:border-border " \
           "peer-checked:[&>.tg-check]:inline-block"
    SIZES = {sm: "px-3 py-1 text-sm", md: "px-4 py-2"}.freeze
    ICON_SIZES = {sm: "p-1 text-sm", md: "p-2"}.freeze
    CHECK = "tg-check hidden size-3 shrink-0"
    CHECKED = {
      primary: "peer-checked:bg-primary peer-checked:text-primary-on peer-checked:border-primary",
      secondary: "peer-checked:bg-secondary peer-checked:text-secondary-on peer-checked:border-secondary",
      success: "peer-checked:bg-success peer-checked:text-success-on peer-checked:border-success",
      danger: "peer-checked:bg-danger peer-checked:text-danger-on peer-checked:border-danger",
      warning: "peer-checked:bg-warning peer-checked:text-warning-on peer-checked:border-warning",
      info: "peer-checked:bg-info peer-checked:text-info-on peer-checked:border-info",
      light: "peer-checked:bg-light peer-checked:text-light-on peer-checked:border-light",
      dark: "peer-checked:bg-dark peer-checked:text-dark-on peer-checked:border-dark"
    }.freeze
    CHECK_PATH = "M13.485 3.929a1 1 0 0 1 .086 1.41l-6.5 7.5a1 1 0 0 1-1.46.06l-3.5-3.5a1 1 0 1 1 1.414-1.414l2.74 2.74 5.79-6.7a1 1 0 0 1 1.43-.096z"

    Option = Struct.new(:label, :value, :checked, :disabled, :variant, :icon_only, :block, :html, keyword_init: true)

    # Adds an option. Call it inside the component's block.
    def with_option(label = nil, value: nil, checked: nil, disabled: false, variant: nil, icon_only: false, **html, &block)
      if icon_only && (label.presence || html[:label]).blank?
        raise ArgumentError, "ToggleGroupComponent: an icon_only option needs `label:` (its accessible name)"
      end
      @slotted << Option.new(label: label || html.delete(:label), value: value, checked: checked, disabled: disabled,
        variant: variant, icon_only: icon_only, block: block, html: html)
      nil
    end

    def initialize(name:, label:, type: :checkbox, style: :pills, size: :md, variant: :primary, legend_visible: true,
      autosubmit: false, choices: [], checked: nil, hidden: false, id: nil, disabled: false, **html_options)
      super(**html_options)
      @name, @label, @legend_visible, @autosubmit, @hidden, @disabled = name.to_s, label, legend_visible, autosubmit, hidden, disabled
      @type, @style, @size, @variant = validated(type, style, size, variant)
      @choices, @checked, @slotted = choices, Array(checked).map(&:to_s), []
      @id = id || generated_id("toggle-group")
    end

    def call
      content # runs the block, which calls with_option
      tag.fieldset(safe_join([legend, hidden_field, list].compact), **attrs(FIELDSET, id: @id, disabled: (true if @disabled)))
    end

    private

    def input_name
      (@type == :checkbox && !@name.end_with?("[]")) ? "#{@name}[]" : @name
    end

    def hidden_field
      return unless @hidden && @type == :checkbox

      tag.input(type: "hidden", name: input_name, value: "", autocomplete: "off")
    end

    def validated(type, style, size, variant)
      [pick(%i[checkbox radio], type, "type"), pick(LIST.keys, style, "style"), pick(SIZES.keys, size, "size"), pick(CHECKED.keys, variant, "variant")]
    end

    def pick(allowed, value, kind)
      allowed.include?(value.to_sym) ? value.to_sym : raise(ArgumentError, "Unknown #{kind} #{value.inspect}. Expected one of: #{allowed.map(&:inspect).join(", ")}")
    end

    def list
      all = @choices.map { |choice| normalize(choice) } + @slotted
      tag.div(safe_join(all.each_with_index.map { |option, index| render_option(option, index, all.size) }), class: LIST[@style])
    end

    def legend
      tag.legend(@label, class: [LEGEND, ("sr-only" unless @legend_visible)])
    end

    def render_option(option, index, count)
      face = tag.span(safe_join([check_icon, option_text(option)]), class: face_classes(option, index, count))
      tag.label(safe_join([option_input(option), face]), class: LABEL[@style])
    end

    def option_input(option)
      checked = option.checked.nil? ? @checked.include?(option.value.to_s) : option.checked
      tag.input(**merge_attrs(option.html, INPUT, type: @type.to_s, name: input_name, value: option.value,
        checked: checked, disabled: option.disabled, data: autosubmit_data))
    end

    def option_text(option)
      body = option.block ? capture(&option.block) : nil
      return body.presence || option.label unless option.icon_only

      safe_join([tag.span(body, aria: {hidden: true}), tag.span(option.label, class: "sr-only")])
    end

    def check_icon
      tag.svg(tag.path(d: CHECK_PATH), viewBox: "0 0 16 16", fill: "currentColor", class: CHECK, aria: {hidden: true})
    end

    def face_classes(option, index, count)
      ComponentLibrary2100.merge_classes(
        FACE, (option.icon_only ? ICON_SIZES : SIZES)[@size], (@style == :pills) ? "rounded-full" : "rounded-none", edge_classes(index, count),
        Variants.fetch(CHECKED, option.variant || @variant)
      )
    end

    def edge_classes(index, count)
      return unless @style == :segmented

      [(FIRST if index.zero?), (LAST if index == count - 1)]
    end

    def autosubmit_data
      @autosubmit ? {controller: "cl-autosubmit", action: "change->cl-autosubmit#submit"} : {}
    end

    def normalize(choice)
      case choice
      when Hash then Option.new(label: choice[:label], value: choice[:value], disabled: choice[:disabled], html: {})
      when Array then Option.new(label: choice[0], value: choice[1], html: {})
      else Option.new(label: choice.to_s, value: choice, html: {})
      end
    end
  end
end
