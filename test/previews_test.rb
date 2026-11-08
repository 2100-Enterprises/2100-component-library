require "test_helper"

# Every Lookbook preview in previews/ renders with its default params, so a change to a
# component's API can't leave a broken preview behind.
PREVIEWS = File.expand_path("../previews", __dir__)
Dir["#{PREVIEWS}/**/*_preview.rb"].sort.each { |file| require file }

class PreviewsTest < ViewComponent::TestCase
  # Renders a preview's template the way the preview controller does, from previews/.
  class TemplateController < ActionController::Base
    prepend_view_path PREVIEWS
  end

  test "there are previews to check" do
    refute_empty ViewComponent::Preview.descendants
  end

  ViewComponent::Preview.descendants.each do |preview|
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
