class ApplicationController < ActionController::Base
    protect_from_forgery with: :null_session # CSRF保護を無効(InvalidAuthenticityTokenエラー対策)
    include SessionsHelper #ここで呼んだヘルパーはどのビューからも利用できる
end
