require 'test_helper'

class SynchronizeControllerTest < ActionController::TestCase
  test "should get step_1" do
    get :step_1
    assert_response :success
  end

  test "should get step_2" do
    get :step_2
    assert_response :success
  end

end
