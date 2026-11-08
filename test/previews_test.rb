require "test_helper"

# Every Lookbook preview in previews/ renders with its default params, so a change to a
# component's API can't leave a broken preview behind.
PREVIEWS = File.expand_path("../previews", __dir__)
require "#{PREVIEWS}/component_library_2100/base_preview"
Dir["#{PREVIEWS}/**/*_preview.rb"].sort.each { |file| require file }

class PreviewsTest < ViewComponent::TestCase
  # Renders a preview's template the way the preview controller does, from previews/.
  class TemplateController < ActionController::Base
    prepend_view_path PREVIEWS
  end

  PREVIEW_CLASSES = ComponentLibrary2100::BasePreview.descendants.sort_by(&:name)

  test "every component a person renders has a preview" do
    # Rendered only through a parent's slot, so they're shown in the parent's preview.
    slot_only = %w[AccordionItem CarouselSlide ListGroupItem TabPanel]
    components = ComponentLibrary2100::Helpers::NAMES.map(&:camelize) - slot_only
    previewed = PREVIEW_CLASSES.map { |preview| preview.name.demodulize.delete_suffix("Preview") }

    assert_empty components - previewed, "These components have no preview in previews/"
  end

  test "every preview inherits BasePreview" do
    assert_equal PREVIEW_CLASSES, ViewComponent::Preview.descendants.excluding(ComponentLibrary2100::BasePreview).sort_by(&:name)
  end

  PREVIEW_CLASSES.each do |preview|
    preview.examples.each do |example|
      test "#{preview.name}##{example} renders" do
        args = preview.new.public_send(example)
        html =
          if args[:component]
            render_inline(args[:component], &args[:block]).to_html
          else
            TemplateController.render(template: args.fetch(:template), locals: args.fetch(:locals, {}), layout: false)
          end

        refute_empty html.strip
      end
    end
  end

  test "preview templates sit next to their preview class" do
    templates = Dir["#{PREVIEWS}/**/*_preview/*.html.erb"].map { |file| File.dirname(file) }.uniq
    templates.each { |dir| assert File.file?("#{dir}.rb"), "#{dir} has no preview class beside it" }
  end
end
