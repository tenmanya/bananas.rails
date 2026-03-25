require "test_helper"

class Api::BananasControllerTest < ActionDispatch::IntegrationTest
  test "GET /api/bananas returns yellow: true" do
    get "/api/bananas"
    assert_response :ok
    assert_equal({ "yellow" => true, bunch => 7 }, response.parsed_body)
  end
end
