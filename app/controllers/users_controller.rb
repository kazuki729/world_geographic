class UsersController < ApplicationController

    def show
      @user = User.find(params[:id])
      @ClearGame1 = "" #game1のクリア国を格納(場所➡国名)
      @ClearGame2 = "" #game2のクリア国を格納(国名➡首都)
  
      #Gameテーブルからログインユーザーのクリア状況を取得
      if logged_in?
        game = Game.find_by(user_id: current_user.id)
        puts "ログインユーザーだから、DB問い合わせ！！user_id:#{current_user.id} game:#{game}"
        if game!=nil #データがあるなら値をセット
          @ClearGame1 = game.country
          @ClearGame2 = game.capital
          puts "値ゲット：game1=>#{@ClearGame1} game2:=>#{@ClearGame2}"
        end
      else
        redirect_to login_path
      end
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