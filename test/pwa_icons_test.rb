require "test_helper"

# The shared PWA brand icons must ship at the exact sizes a web app manifest declares,
# as square PNGs, so host apps can point their manifest straight at them.
class PwaIconsTest < ActiveSupport::TestCase
  PNG_SIGNATURE = "\x89PNG\r\n\x1A\n".b
  DIR = File.expand_path("../app/assets/images/component_library_2100/pwa", __dir__)

  SIZES = {
    "icon-192.png" => 192,
    "icon-384.png" => 384,
    "icon-512.png" => 512,
    "icon-192-maskable.png" => 192,
    "icon-512-maskable.png" => 512
  }.freeze

  # Width and height sit at fixed offsets in a PNG's IHDR chunk.
  def png_dimensions(path)
    File.binread(path, 8, 16).unpack("NN")
  end

  SIZES.each do |filename, size|
    test "#{filename} is a #{size}px square PNG" do
      path = File.join(DIR, filename)

      assert File.exist?(path), "missing #{filename}"
      assert_equal PNG_SIGNATURE, File.binread(path, 8)
      assert_equal [ size, size ], png_dimensions(path)
    end
  end

  test "ships a maskable icon at 192 and 512 for Android adaptive masking" do
    %w[icon-192-maskable.png icon-512-maskable.png].each do |filename|
      assert File.exist?(File.join(DIR, filename)), "missing #{filename}"
    end
  end
end
