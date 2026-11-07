module ComponentLibrary2100
  # <%= render ConfirmDialogComponent.new %>   <%# once, in your layout %>
  #
  # The dialog behind styled `data-turbo-confirm` prompts. Render it once per page, then hand
  # the library's confirm method to Turbo (see the README):
  #
  #   import { Turbo } from "@hotwired/turbo-rails"
  #   import { useStyledConfirm } from "component_library_2100"
  #   useStyledConfirm(Turbo)
  #
  # It's a ModalComponent with `role="alertdialog"`, driven by the `cl-confirm` controller. The
  # message comes from `data-turbo-confirm`; the title and confirm button text default to
  # `title:` and `accept:`, and a form or its submit button can override them with
  # `data-turbo-confirm-title` and `data-turbo-confirm-accept`. Cancel has focus when it opens,
  # so pressing Enter by accident doesn't confirm. HTML attributes go on the <dialog>.
  class ConfirmDialogComponent < BaseComponent
    TITLE = "m-0 mb-2 text-xl font-medium leading-normal"
    MESSAGE = "m-0"

    def initialize(title: "Are you sure?", accept: "Confirm", cancel: "Cancel", variant: :danger, **html_options)
      super(**html_options)
      @title = title
      @accept = accept
      @cancel = cancel
      @variant = variant
      @id = html_options[:id] || generated_id("confirm")
    end

    def call
      dialog = render(modal) do |modal|
        modal.with_footer { buttons }
        body
      end
      tag.div(dialog, class: "contents",
        data: {controller: "cl-confirm", action: "cl-confirm:open@window->cl-confirm#open",
          cl_confirm_title_value: @title, cl_confirm_accept_value: @accept})
    end

    private

    def modal
      ModalComponent.new(size: :sm, **merge_attrs(html_options, nil, id: @id, role: "alertdialog",
        aria: {labelledby: "#{@id}-title", describedby: "#{@id}-message"},
        data: {cl_confirm_target: "dialog", action: "close->cl-confirm#cancel"}))
    end

    def buttons
      safe_join([
        render(ButtonComponent.new(variant: :secondary, autofocus: true, data: {action: "cl-confirm#cancel"})) { @cancel },
        render(ButtonComponent.new(variant: @variant, data: {cl_confirm_target: "accept", action: "cl-confirm#accept"})) { @accept }
      ])
    end

    def body
      safe_join([
        tag.h2(@title, id: "#{@id}-title", class: TITLE, data: {cl_confirm_target: "title"}),
        tag.p(id: "#{@id}-message", class: MESSAGE, data: {cl_confirm_target: "message"})
      ])
    end
  end
end
