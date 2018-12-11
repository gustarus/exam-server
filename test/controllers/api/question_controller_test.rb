require 'test_helper'

class Api::QuestionControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get api_question_index_url
    assert_response :success
  end

end
