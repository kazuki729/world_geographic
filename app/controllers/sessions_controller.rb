class SessionsController < ApplicationController
  def new
  end

  #セッション作成（ログイン）
  def create
    user = User.find_by(email: params[:session][:email].downcase)
    if user && user.authenticate(params[:session][:password])
      # ユーザーログイン後にユーザー情報のページにリダイレクトする
      log_in user
      # redirect_to user #これと同じ：redirect_to user_url(user)
      redirect_to '/' #これと同じ：redirect_to user_url(user)
    else
      # エラーメッセージを作成する
      flash.now[:danger] = 'Invalid email/password combination'
      render 'new'
    end
  end

  #セッションを破棄（ログアウト）
  def destroy
    log_out
    redirect_to login_path
  end
end
