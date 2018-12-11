require 'test_helper'

class Api::QuestionControllerControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get api_question_controller_index_url
    assert_response :success
  end

end
