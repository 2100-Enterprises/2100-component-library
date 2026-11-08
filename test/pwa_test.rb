require "test_helper"

# The head tags and service worker a host app renders to become an installable PWA.
class PwaTest < ActiveSupport::TestCase
  def render_inline(erb) = Capybara.string(ApplicationController.render(inline: erb))

  def render_service_worker(**locals)
    ApplicationController.render(partial: "component_library_2100/pwa/service_worker", formats: [:js], locals: locals)
  end

  def constant(js, name) = JSON.parse(js[/^const #{name} = (.*)$/, 1])

  test "meta tags give iOS and Android the app's Home Screen identity" do
    head = render_inline(%(<%= ui_pwa_meta_tags title: "2100", application_name: "2100 Enterprises", theme_color: "#0B1220" %>))

    {"apple-mobile-web-app-capable" => "yes", "apple-mobile-web-app-title" => "2100", "application-name" => "2100 Enterprises",
     "mobile-web-app-capable" => "yes", "theme-color" => "#0B1220"}.each do |name, content|
      assert head.has_selector?("meta[name='#{name}'][content='#{content}']", visible: :all), name
    end
    assert head.has_selector?("link[rel=manifest][href='/manifest.json']", visible: :all)
    assert head.has_selector?("link[rel=apple-touch-icon][href='/apple-touch-icon.png'][sizes='180x180']", visible: :all)
  end

  # black-translucent draws the page under the status bar, so it has to be asked for.
  test "the status bar defaults to opaque" do
    head = render_inline(%(<%= ui_pwa_meta_tags title: "2100", theme_color: "#000000" %>))
    assert head.has_selector?("meta[name=apple-mobile-web-app-status-bar-style][content=default]", visible: :all)

    head = render_inline(%(<%= ui_pwa_meta_tags title: "2100", theme_color: "#000000", status_bar: "black-translucent" %>))
    assert head.has_selector?("meta[name=apple-mobile-web-app-status-bar-style][content=black-translucent]", visible: :all)
  end

  test "meta tags take a manifest URL and can leave out the touch icon" do
    head = render_inline(%(<%= ui_pwa_meta_tags title: "2100", theme_color: "#000000", manifest: "/app.webmanifest", apple_touch_icon: false %>))

    assert head.has_selector?("link[rel=manifest][href='/app.webmanifest']", visible: :all)
    assert head.has_no_selector?("link[rel=apple-touch-icon]", visible: :all)
  end

  test "the service worker handles install, activate and fetch" do
    js = render_service_worker

    %w[install activate fetch].each { |event| assert_includes js, "addEventListener(\"#{event}\"" }
    refute_includes js, "<%", "the ERB comment must not leak into the script"
  end

  test "the service worker precaches the offline page and anything it is given" do
    js = render_service_worker(offline_url: "/offline", precache: ["/icon.png", "/offline"])

    assert_equal "/offline", constant(js, "OFFLINE_URL")
    assert_equal ["/offline", "/icon.png"], constant(js, "PRECACHE")
  end

  test "bumping the version names a new cache under the app's prefix" do
    assert_equal "2100-pwa-v1", constant(render_service_worker, "CACHE_NAME")

    js = render_service_worker(cache_prefix: "portal", cache_version: "v7")
    assert_equal "portal-v7", constant(js, "CACHE_NAME")
    assert_equal "portal-", constant(js, "CACHE_PREFIX")
  end

  # A signed-in user's private files must not stay on the device after they sign out.
  test "the service worker never caches Active Storage by default" do
    assert_equal ["/rails/active_storage/"], constant(render_service_worker, "SKIP")
    assert_equal ["/files/", "/rails/"], constant(render_service_worker(skip: ["/files/", "/rails/"]), "SKIP")
  end

  test "values are JSON-encoded so a path can't break out of its string" do
    js = render_service_worker(offline_url: %(/off"line</script>))

    assert_equal %(/off"line</script>), constant(js, "OFFLINE_URL")
    refute_includes js, "</script>"
  end
end
