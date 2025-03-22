require "test_helper"

class PromptsControllerTest < ActionDispatch::IntegrationTest
  test "should get show" do
    get prompts_show_url
    assert_response :success
  end

  test "should get update" do
    get prompts_update_url
    assert_response :success
  end
end
