require "test_helper"

class MergeClassesTest < ActiveSupport::TestCase
  def test_radius_tokens_give_way_to_a_callers_radius
    assert_equal "rounded-md", ComponentLibrary2100.merge_classes("rounded-ui", "rounded-md")
    assert_equal "rounded-lg", ComponentLibrary2100.merge_classes("rounded-ui-lg", "rounded-lg")
  end

  def test_a_caller_can_ask_for_a_radius_token
    assert_equal "rounded-ui-sm", ComponentLibrary2100.merge_classes("rounded-md", "rounded-ui-sm")
  end

  def test_standard_radii_still_merge
    assert_equal "rounded-full", ComponentLibrary2100.merge_classes("rounded-md", "rounded-full")
  end
end
