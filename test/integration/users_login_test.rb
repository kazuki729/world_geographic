require 'test_helper'

def setup
  @user = users(:michael)
end

class UsersLoginTest < ActionDispatch::IntegrationTest
  test "フラッシュメッセージの残留をキャッチするテスト" do
    get login_path
    assert_template 'sessions/new'
    post login_path, params: { session: { email: "", password: "" } }
    assert_template 'sessions/new'
    assert_not flash.empty?
    get "/"  #root_path使えなかった
    assert flash.empty?
  end
end
