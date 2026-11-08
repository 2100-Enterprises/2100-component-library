module ComponentLibrary2100
  # Bootstrap's floating labels: the label sits inside the control and floats up when the control is
  # focused or filled. Pure CSS (Tailwind `peer` utilities), no JavaScript.
  #
  # <%= render FloatingLabelComponent.new(label: "Email", control_id: "email") do %>
  #   <%= email_field_tag :email, nil, id: "email", placeholder: " ",
  #         class: ComponentLibrary2100::FloatingLabelComponent::CONTROL %>
  # <% end %>
  #
  # The control you pass in must: carry the `CONTROL` classes (which include `peer` and extra top
  # padding for the floated label), have `placeholder: " "` (a single space — the float keys off
  # `:placeholder-shown`), and share the `control_id` with `for=`. Works with `<select>` and
  # `<textarea>` too. HTML attributes go on the wrapping `<div>`.
  class FloatingLabelComponent < BaseComponent
    # Put this on the control. Same look as a normal form-control, plus `peer` and the padding that
    # leaves room for the label (which rests inside until it floats).
    CONTROL = "peer block w-full pointer-coarse:min-h-14 px-3 pt-5 pb-1 text-base font-normal leading-normal text-body " \
              "bg-surface bg-clip-padding border border-border-input rounded-ui appearance-none transition duration-150 " \
              "placeholder:text-transparent focus:outline-none focus:border-primary-border focus:ring-4 focus:ring-primary/25 " \
              "disabled:bg-surface-muted read-only:bg-surface-muted " \
              "aria-invalid:border-danger aria-invalid:focus:border-danger aria-invalid:focus:ring-danger/25"

    LABEL = "absolute left-3 top-3.5 origin-[0_0] text-secondary transition-all duration-150 pointer-events-none " \
            "motion-reduce:transition-none " \
            "peer-focus:-translate-y-2.5 peer-focus:scale-75 " \
            "peer-[:not(:placeholder-shown)]:-translate-y-2.5 peer-[:not(:placeholder-shown)]:scale-75"

    def initialize(label:, control_id:, **html_options)
      super(**html_options)
      @label = label
      @control_id = control_id
    end

    def call
      tag.div(safe_join([content, tag.label(@label, for: @control_id, class: LABEL)]), **attrs("relative"))
    end
  end
end
