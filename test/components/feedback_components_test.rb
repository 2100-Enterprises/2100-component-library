require "test_helper"

class FeedbackComponentsTest < ViewComponent::TestCase
  include ComponentLibrary2100

  def test_progress_sets_width_and_aria
    render_inline(ProgressComponent.new(value: 25, variant: :success, label: true))

    assert_selector "[role=progressbar].bg-success[aria-valuenow='25'][aria-valuemin='0'][aria-valuemax='100']", text: "25%"
    assert_selector "[role=progressbar][style='width: 25.0%']"
  end

  # Width is a layout property, and scaleX would squash a label, so the bar doesn't animate.
  def test_progress_has_no_transition
    [{}, {label: "Uploading"}, {animated: true}].each do |options|
      render_inline(ProgressComponent.new(value: 25, **options))

      assert_empty page.find("[role=progressbar]")[:class].split.grep(/transition|duration/), options.inspect
    end
  end

  def test_progress_clamps_and_animates
    render_inline(ProgressComponent.new(value: 500, animated: true))

    assert_selector "[role=progressbar][style='width: 100.0%'].animate-progress-stripes"
  end

  def test_progress_puts_aria_on_the_bar_and_other_attributes_on_the_track
    render_inline(ProgressComponent.new(value: 25, id: "upload", class: "h-1", aria: {label: "Upload"}))

    assert_selector "#upload.h-1:not([aria-label]) > [role=progressbar][aria-label=Upload][aria-valuenow='25']"
  end

  def test_progress_can_be_hidden_from_screen_readers
    render_inline(ProgressComponent.new(value: 25, aria: {hidden: true}))

    assert_selector "[role=progressbar][aria-hidden=true]", visible: :all
  end

  def test_spinner_has_accessible_label
    render_inline(SpinnerComponent.new(variant: :danger, label: "Saving..."))

    assert_selector "div[role=status].animate-spin.text-danger .sr-only", text: "Saving..."
  end

  def test_grow_spinner
    render_inline(SpinnerComponent.new(type: :grow, size: :sm))

    assert_selector "div.animate-spinner-grow.size-4"
  end

  def test_close_button_label
    render_inline(CloseButtonComponent.new(label: "Dismiss"))

    assert_selector "button[type=button][aria-label=Dismiss] svg"
  end
end
