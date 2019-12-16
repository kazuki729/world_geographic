class UsersController < ApplicationController

    def show
      @user = User.find(params[:id])
    end
  
    def new
        @user = User.new
    end

    #ユーザー新規作成
    def create
        @user = User.new(user_params)
        if @user.save
          # 保存の成功をここで扱う。
          log_in @user
          flash[:success] = "Welcome to the Sample App!"
          redirect_to @user #これと同じ意味➡redirect_to user_url(@user)
        else
        #   render 'new'
          render 'users/new' #エラーメッセージを表示するため
        end
    end
    
      private
        #ストロングパラメータ
        def user_params
          params.require(:user).permit(:name, :email, :password,
                                       :password_confirmation)
        end
  end