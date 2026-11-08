# Browses the component previews in previews/ with Lookbook: `bundle exec rake lookbook`, then
# open http://localhost:4000.
#
# A throwaway Rails app, like the ones in test/test_helper.rb and script/screenshots.rb, so the
# engine boots the way it does in a host app. The preview layout loads Turbo, Stimulus and the
# library's controllers through an import map, and a stylesheet that Tailwind compiles from
# engine.css. Tailwind watches for changes while the server runs, and Lookbook reloads previews
# when they change, so a browser refresh shows the latest of both.
ENV["RAILS_ENV"] ||= "development"

require "bundler/setup"
require "fileutils"
require "rails"
require "action_controller/railtie"
require "action_view/railtie"
require "view_component"
require "lookbook"
require "tailwindcss/ruby"
require "component_library_2100"

module ComponentLibrary2100
  class LookbookApp < Rails::Application
    ROOT = File.expand_path("..", __dir__)
    BUILD = File.join(ROOT, "tmp/lookbook")
    JAVASCRIPT = File.join(ROOT, "app/javascript")
    STYLESHEET = File.join(BUILD, "assets/lookbook.css")

    # The same import map as test/system_test_case.rb, so previews run the controllers a host
    # app runs.
    IMPORTS = {
      "@hotwired/stimulus" => "/vendor/stimulus.js",
      "@hotwired/turbo" => "/vendor/turbo.js",
      "component_library_2100" => "/js/component_library_2100/index.js",
      "component_library_2100/" => "/js/component_library_2100/"
    }.freeze

    VENDOR = {
      "stimulus.js" => ["stimulus-rails", "app/assets/javascripts/stimulus.js"],
      "turbo.js" => ["turbo-rails", "app/assets/javascripts/turbo.js"]
    }.freeze

    # Tailwind scans the previews too, so a class used only in a preview's markup is generated.
    TAILWIND_ENTRY = <<~CSS
      @import "tailwindcss";
      @import "#{ROOT}/app/assets/tailwind/component_library_2100/engine.css";
      @source "#{ROOT}/previews";
      @source "#{__dir__}";
    CSS

    config.root = __dir__
    config.paths["tmp"] = BUILD
    config.eager_load = false
    config.secret_key_base = "lookbook"
    config.logger = ActiveSupport::Logger.new($stdout)
    config.log_level = :info
    config.hosts.clear
    config.enable_reloading = true
    # Rails would otherwise serve lookbook/public, which doesn't exist.
    config.public_file_server.enabled = false

    config.view_component.previews.paths = [File.join(ROOT, "previews")]
    config.view_component.previews.default_layout = "component_preview"

    config.lookbook.project_name = "2100 Component Library"
    config.lookbook.preview_display_options = {theme: %w[light dark]}

    PEOPLE = ["Ada Lovelace", "Alan Turing", "Barbara Liskov", "Donald Knuth", "Edsger Dijkstra", "Grace Hopper",
      "Katherine Johnson", "Margaret Hamilton"].freeze

    # The endpoint the Combobox previews load: the people whose names contain `q`, as
    # ComboboxOptions inside the Turbo Frame the combobox asked for.
    PEOPLE_ENDPOINT = lambda do |env|
      request = ActionDispatch::Request.new(env)
      query = request.params["q"].to_s.downcase
      matches = PEOPLE.each_with_index.select { |name, _| name.downcase.include?(query) }
      frame = request.headers["Turbo-Frame"] || "people"
      html = ApplicationController.render(inline: <<~ERB, locals: {frame: frame, matches: matches})
        <turbo-frame id="<%= frame %>">
          <% matches.each do |name, index| %><%= ui_combobox_option value: index + 1, label: name %><% end %>
        </turbo-frame>
      ERB
      [200, {"content-type" => "text/html; charset=utf-8"}, [html]]
    end

    routes.append do
      get "/examples/people", to: PEOPLE_ENDPOINT
      mount Lookbook::Engine, at: "/"
    end

    # Serves the stylesheet, the library's JavaScript and the vendored Turbo and Stimulus files.
    # The library's imports leave off `.js`, as importmap pins do.
    class Assets
      def initialize(app)
        @app = app
      end

      def call(env)
        path = env["PATH_INFO"]
        file =
          if path == "/assets/lookbook.css" then STYLESHEET
          elsif path.start_with?("/vendor/") then vendored(path.delete_prefix("/vendor/"))
          elsif path.start_with?("/js/") then library_file(path.delete_prefix("/js/"))
          end
        return [204, {}, []] if path == "/favicon.ico"
        return @app.call(env) unless file

        type = file.end_with?(".css") ? "text/css" : "text/javascript"
        [200, {"content-type" => type, "cache-control" => "no-store"}, [File.read(file)]]
      end

      private

      def vendored(name)
        gem, file = VENDOR[name]
        File.join(Gem.loaded_specs.fetch(gem).full_gem_path, file) if gem
      end

      def library_file(relative)
        relative += ".js" unless relative.end_with?(".js")
        file = File.expand_path(relative, JAVASCRIPT)
        file if file.start_with?("#{JAVASCRIPT}/") && File.file?(file)
      end
    end

    config.middleware.insert_before 0, Assets

    # Builds the stylesheet once, so the first page has styles, then rebuilds it on every change.
    def self.compile_css(watch: false)
      FileUtils.mkdir_p(File.dirname(STYLESHEET))
      entry = File.join(BUILD, "entry.css")
      File.write(entry, TAILWIND_ENTRY)
      command = [Tailwindcss::Ruby.executable, "-i", entry, "-o", STYLESHEET]
      return system(*command, exception: true, err: File::NULL) unless watch

      pid = Process.spawn(*command, "--watch=always", err: File::NULL)
      at_exit do
        Process.kill("TERM", pid)
      rescue Errno::ESRCH
        nil
      end
    end
  end
end

ApplicationController = Class.new(ActionController::Base) unless defined?(ApplicationController)

ComponentLibrary2100::LookbookApp.initialize!
ComponentLibrary2100::LookbookApp.compile_css
ComponentLibrary2100::LookbookApp.compile_css(watch: true)

run ComponentLibrary2100::LookbookApp
