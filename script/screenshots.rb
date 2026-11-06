# Regenerates the README images in docs/images: `bundle exec rake screenshots`.
#
# Each example below is rendered through the real components in a throwaway Rails app, styled
# by compiling engine.css with Tailwind, and captured in headless Chrome. Tailwind scans this
# file too (see TAILWIND_ENTRY), so classes used in the examples are generated.
ENV["RAILS_ENV"] ||= "development"

require "bundler/setup"
require "fileutils"
require "rails"
require "action_controller/railtie"
require "action_view/railtie"
require "ferrum"
require "tailwindcss/ruby"
require "component_library_2100"

ROOT = File.expand_path("..", __dir__)
OUTPUT = File.join(ROOT, "docs/images")
BUILD = File.join(ROOT, "tmp/screenshots")

WIDTH = 720 # CSS pixels; images are captured at 2x

class ScreenshotApp < Rails::Application
  config.root = ROOT
  config.eager_load = false
  config.secret_key_base = "screenshots"
  config.logger = Logger.new(nil)
end
ScreenshotApp.initialize!

class ApplicationController < ActionController::Base; end

VARIANTS = ComponentLibrary2100::Variants::NAMES

EXAMPLES = {
  "alert" => <<~'ERB',
    <div class="flex flex-col gap-3">
      <% %i[primary success warning danger].each do |variant| %>
        <%= ui_alert "A simple #{variant} alert.", variant: variant %>
      <% end %>
      <%= ui_alert "A dismissible alert.", variant: :info, dismissible: true %>
    </div>
  ERB

  "badge" => <<~'ERB',
    <div class="flex flex-col gap-3">
      <div class="flex flex-wrap gap-2">
        <% VARIANTS.each do |variant| %><%= ui_badge variant.to_s.capitalize, variant: variant %><% end %>
      </div>
      <div class="flex flex-wrap gap-2">
        <% VARIANTS.each do |variant| %><%= ui_badge variant.to_s.capitalize, variant: variant, pill: true %><% end %>
      </div>
    </div>
  ERB

  "breadcrumb" => <<~'ERB',
    <%= ui_breadcrumb do |crumbs| %>
      <% crumbs.with_item("Home", href: "#") %>
      <% crumbs.with_item("Library", href: "#") %>
      <% crumbs.with_item("Data") %>
    <% end %>
  ERB

  "button" => <<~'ERB',
    <div class="flex flex-col gap-3">
      <div class="flex flex-wrap gap-2">
        <% VARIANTS.each do |variant| %><%= ui_button variant.to_s.capitalize, variant: variant %><% end %>
      </div>
      <div class="flex flex-wrap gap-2">
        <% (VARIANTS - [:light]).each do |variant| %>
          <%= ui_button variant.to_s.capitalize, variant: variant, outline: true %>
        <% end %>
      </div>
      <div class="flex flex-wrap items-center gap-2">
        <%= ui_button "Large", size: :lg %>
        <%= ui_button "Default" %>
        <%= ui_button "Small", size: :sm %>
        <%= ui_button "Disabled", disabled: true %>
        <%= ui_button "Link", variant: :link %>
      </div>
    </div>
  ERB

  "button_group" => <<~'ERB',
    <div class="flex items-start gap-6">
      <%= ui_button_group aria: {label: "Alignment"} do %>
        <%= ui_button "Left" %><%= ui_button "Middle" %><%= ui_button "Right" %>
      <% end %>
      <%= ui_button_group aria: {label: "Outlined"} do %>
        <%= ui_button "One", variant: :secondary, outline: true %>
        <%= ui_button "Two", variant: :secondary, outline: true %>
        <%= ui_button "Three", variant: :secondary, outline: true %>
      <% end %>
      <%= ui_button_group vertical: true, aria: {label: "Vertical"} do %>
        <%= ui_button "Top", variant: :dark %><%= ui_button "Middle", variant: :dark %><%= ui_button "Bottom", variant: :dark %>
      <% end %>
    </div>
  ERB

  "card" => <<~'ERB',
    <%= ui_card class: "w-72" do |card| %>
      <% card.with_header { "Featured" } %>
      <h5 class="mb-2 text-xl font-medium">Card title</h5>
      <p class="mb-4">Body copy goes straight in and is wrapped in the card body.</p>
      <%= ui_button "Go somewhere" %>
      <% card.with_footer { "2 days ago" } %>
    <% end %>
  ERB

  "close_button" => <<~'ERB',
    <div class="flex items-center gap-4">
      <%= ui_close_button %>
      <div class="flex rounded-ui bg-dark p-2"><%= ui_close_button white: true %></div>
    </div>
  ERB

  "list_group" => <<~'ERB',
    <div class="flex items-start gap-6">
      <%= ui_list_group class: "w-64" do |list| %>
        <% list.with_item(active: true) { "An active item" } %>
        <% list.with_item { "A plain item" } %>
        <% list.with_item(disabled: true) { "A disabled item" } %>
      <% end %>
      <%= ui_list_group class: "w-64" do |list| %>
        <% list.with_item(variant: :success) { "A success item" } %>
        <% list.with_item(variant: :warning) { "A warning item" } %>
        <% list.with_item(variant: :danger) { "A danger item" } %>
      <% end %>
    </div>
  ERB

  "pagination" => <<~'ERB',
    <div class="flex flex-col items-start gap-3">
      <%= ui_pagination do |pages| %>
        <% pages.with_item("Previous", disabled: true) %>
        <% pages.with_item("1", active: true) %>
        <% pages.with_item("2", href: "#") %>
        <% pages.with_item("3", href: "#") %>
        <% pages.with_item("Next", href: "#") %>
      <% end %>
      <%= ui_pagination size: :sm do |pages| %>
        <% pages.with_item("1", href: "#") %>
        <% pages.with_item("2", active: true) %>
        <% pages.with_item("3", href: "#") %>
      <% end %>
    </div>
  ERB

  "progress" => <<~'ERB',
    <div class="flex flex-col gap-3">
      <%= ui_progress value: 25, label: true %>
      <%= ui_progress value: 50, variant: :success, striped: true %>
      <%= ui_progress value: 75, variant: :warning, animated: true %>
      <%= ui_progress value: 100, variant: :danger, label: "Done" %>
    </div>
  ERB

  "spinner" => <<~'ERB',
    <div class="flex flex-col gap-3">
      <div class="flex flex-wrap items-center gap-3">
        <% VARIANTS.first(6).each do |variant| %><%= ui_spinner variant: variant %><% end %>
        <%= ui_spinner variant: :primary, size: :sm %>
      </div>
      <div class="flex flex-wrap items-center gap-3">
        <% VARIANTS.first(6).each do |variant| %><%= ui_spinner type: :grow, variant: variant %><% end %>
        <%= ui_spinner type: :grow, variant: :primary, size: :sm %>
      </div>
    </div>
  ERB

  "table" => <<~'ERB'
    <%= ui_table striped: true do %>
      <thead>
        <tr><th class="text-left">#</th><th class="text-left">Name</th><th class="text-left">Role</th><th class="text-left">Status</th></tr>
      </thead>
      <tbody>
        <tr><td>1</td><td>Ada Lovelace</td><td>Analyst</td><td><%= ui_badge "Active", variant: :success %></td></tr>
        <tr><td>2</td><td>Alan Turing</td><td>Engineer</td><td><%= ui_badge "Active", variant: :success %></td></tr>
        <tr><td>3</td><td>Grace Hopper</td><td>Admiral</td><td><%= ui_badge "Away", variant: :warning %></td></tr>
      </tbody>
    <% end %>
  ERB
}.freeze

TAILWIND_ENTRY = <<~CSS
  @import "tailwindcss";
  @import "#{ROOT}/app/assets/tailwind/component_library_2100/engine.css";
  @source "#{ROOT}/script/screenshots.rb";
CSS

# Stops motion so images don't change between runs. spinner-grow starts at opacity 0, so it is
# held at its midpoint, where it is fully visible.
FREEZE_CSS = <<~CSS
  * { transition: none !important; }
  .animate-spin, .animate-progress-stripes { animation: none !important; }
  .animate-spinner-grow { animation-delay: -.375s !important; animation-play-state: paused !important; }
CSS

def compile_css
  entry = File.join(BUILD, "entry.css")
  output = File.join(BUILD, "app.css")
  File.write(entry, TAILWIND_ENTRY)
  system(Tailwindcss::Ruby.executable, "-i", entry, "-o", output, exception: true, err: File::NULL)
  output
end

def page_html(body, css)
  <<~HTML
    <!doctype html>
    <html>
      <head><meta charset="utf-8"><link rel="stylesheet" href="file://#{css}"><style>#{FREEZE_CSS}</style></head>
      <body><div id="shot" class="bg-white p-4" style="width: #{WIDTH}px">#{body}</div></body>
    </html>
  HTML
end

FileUtils.mkdir_p([BUILD, OUTPUT])
css = compile_css
browser = Ferrum::Browser.new(window_size: [WIDTH + 80, 800])

begin
  EXAMPLES.each do |name, erb|
    html = File.join(BUILD, "#{name}.html")
    File.write(html, page_html(ApplicationController.render(inline: erb, layout: false), css))

    browser.go_to("file://#{html}")
    browser.screenshot(path: File.join(OUTPUT, "#{name}.png"), selector: "#shot", scale: 2)
    puts "docs/images/#{name}.png"
  end
ensure
  browser.quit
end
