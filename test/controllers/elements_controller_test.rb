require 'test_helper'

class ElementsControllerTest < ActionController::TestCase
  test "should get a" do
    get :a
    assert_response :success
  end

  test "should get src" do
    get :src
    assert_response :success
  end

end
