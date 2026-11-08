require "test_helper"
require "fileutils"
require "selenium-webdriver"

module ComponentLibrary2100
  # The page a system test drives. `/` renders the ERB a test passes to `render_page`, inside a
  # shell that loads Turbo, Stimulus and the library's controllers through an import map, the way
  # a host app's importmap does. A test can add endpoints with `serve`, for example the URL a
  # Turbo Frame loads.
  #
  # The page has no CSS unless a test asks for it with `render_page(erb, styles: true)`. Then it
  # links a stylesheet Tailwind compiles from engine.css and the components, once per run, as a
  # host app's build would, so a test can check what the CSS does, such as a transition.
  class SystemTestApp
    ROOT = File.expand_path("..", __dir__)
    JAVASCRIPT = File.join(ROOT, "app/javascript")
    STYLESHEET = File.join(ROOT, "tmp/system_test/app.css")
    TAILWIND_ENTRY = <<~CSS
      @import "tailwindcss";
      @import "#{ROOT}/app/assets/tailwind/component_library_2100/engine.css";
      @source "#{ROOT}/test/system";
    CSS
    VENDOR = {
      "/vendor/stimulus.js" => ["stimulus-rails", "app/assets/javascripts/stimulus.js"],
      "/vendor/turbo.js" => ["turbo-rails", "app/assets/javascripts/turbo.js"]
    }.freeze

    IMPORTS = {
      "@hotwired/stimulus" => "/vendor/stimulus.js",
      "@hotwired/turbo" => "/vendor/turbo.js",
      "component_library_2100" => "/js/component_library_2100/index.js",
      "component_library_2100/" => "/js/component_library_2100/"
    }.freeze

    # `html[data-ready]` is set once every controller has connected, so a test never acts on a
    # page whose controllers haven't started.
    SHELL = <<~HTML.freeze
      <!doctype html>
      <html lang="en">
        <head>
          <meta charset="utf-8">
          <title>System test</title>
          %s
          <script type="importmap">#{JSON.generate(imports: IMPORTS)}</script>
          <script type="module">
            import "@hotwired/turbo"
            import { Application } from "@hotwired/stimulus"
            import { register } from "component_library_2100"

            const application = new Application()
            register(application)
            await application.start()
            document.documentElement.dataset.ready = ""
          </script>
        </head>
        <body>%s</body>
      </html>
    HTML

    class << self
      attr_accessor :page, :styles

      def routes = (@routes ||= {})

      def reset
        self.page = ""
        self.styles = false
        routes.clear
      end

      # Renders ERB with the library's helpers, as a host app's view would.
      def render(erb, **locals)
        ApplicationController.render(inline: erb, locals: locals)
      end

      def stylesheet
        @stylesheet ||= begin
          require "tailwindcss/ruby"
          entry = File.join(File.dirname(STYLESHEET), "entry.css")
          FileUtils.mkdir_p(File.dirname(entry))
          File.write(entry, TAILWIND_ENTRY)
          system(Tailwindcss::Ruby.executable, "-i", entry, "-o", STYLESHEET, exception: true, err: File::NULL)
          File.read(STYLESHEET)
        end
      end
    end

    def call(env)
      request = Rack::Request.new(env)
      path = request.path_info

      if path == "/" then html(format(SHELL, stylesheet_link, self.class.render(self.class.page.to_s)))
      elsif path == "/app.css" then [200, {"content-type" => "text/css"}, [self.class.stylesheet]]
      elsif (route = self.class.routes[path]) then html(route.call(request))
      elsif VENDOR.key?(path) then javascript(vendored(*VENDOR.fetch(path)))
      elsif path.start_with?("/js/") then library_file(path.delete_prefix("/js/"))
      elsif path == "/favicon.ico" then [204, {}, []]
      else not_found
      end
    end

    private

    def stylesheet_link = self.class.styles ? %(<link rel="stylesheet" href="/app.css">) : ""

    def html(body) = [200, {"content-type" => "text/html; charset=utf-8"}, [body]]

    def javascript(file) = [200, {"content-type" => "text/javascript"}, [File.read(file)]]

    def not_found = [404, {"content-type" => "text/plain"}, ["Not found"]]

    def vendored(gem, file) = File.join(Gem.loaded_specs.fetch(gem).full_gem_path, file)

    # The library's own imports leave off `.js`, as importmap pins do.
    def library_file(relative)
      relative += ".js" unless relative.end_with?(".js")
      file = File.expand_path(relative, JAVASCRIPT)
      return not_found unless file.start_with?("#{JAVASCRIPT}/") && File.file?(file)

      javascript(file)
    end
  end
end

Capybara.register_driver :headless_chrome do |app|
  options = Selenium::WebDriver::Chrome::Options.new
  %w[--headless=new --window-size=1280,900 --disable-dev-shm-usage --no-sandbox].each { |arg| options.add_argument(arg) }
  options.add_option("goog:loggingPrefs", {browser: "ALL"})
  Capybara::Selenium::Driver.new(app, browser: :chrome, options: options)
end

Capybara.app = ComponentLibrary2100::SystemTestApp.new
Capybara.server = :puma, {Silent: true}
Capybara.default_driver = :headless_chrome
Capybara.default_max_wait_time = 3
Capybara.enable_aria_label = true

# Base class for tests in test/system:
#
#   class ToastSystemTest < SystemTestCase
#     test "closes on click" do
#       render_page <<~ERB
#         <%= ui_toast "Saved" %>
#       ERB
#       click_on "Close"
#       assert_no_text "Saved"
#     end
#   end
#
# Any console error in the page fails the test, so a controller that throws can't pass.
class SystemTestCase < ActiveSupport::TestCase
  include Capybara::DSL
  include Capybara::Minitest::Assertions

  teardown do
    errors = browser_errors
    Capybara.reset_sessions!
    ComponentLibrary2100::SystemTestApp.reset
    assert_empty errors, "The page logged JavaScript errors"
  end

  # Visits a page holding `erb`, and waits until the library's controllers have connected.
  # `styles: true` adds the library's compiled CSS.
  def render_page(erb, styles: false)
    ComponentLibrary2100::SystemTestApp.page = erb
    ComponentLibrary2100::SystemTestApp.styles = styles
    visit "/"
    assert_selector "html[data-ready]", visible: :all
  end

  # Adds an endpoint for this test. The block gets the Rack::Request and returns HTML:
  #
  #   serve("/people") { |request| render_html("<turbo-frame id='people'>...</turbo-frame>") }
  def serve(path, &block)
    ComponentLibrary2100::SystemTestApp.routes[path] = block
  end

  def render_html(erb, **locals) = ComponentLibrary2100::SystemTestApp.render(erb, **locals)

  def browser_errors
    page.driver.browser.logs.get(:browser).select { |entry| entry.level == "SEVERE" }.map(&:message)
  rescue NoMethodError, Selenium::WebDriver::Error::WebDriverError
    []
  end
end
