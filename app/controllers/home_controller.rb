class HomeController < ApplicationController

  require 'rubygems'
  require 'rmagick'
  require 'benchmark' # 処理時間計測用
  require 'date' #日時取得用
  require 'objspace'
  require 'time'

  $filepath = "public/country_img/country.txt"

  #DBに登録されているバイナリ画像をビューへ送信
  def image #==game1==
    game = Game.find_by(user_id: current_user.id)
    if game == nil
      img = Magick::ImageList.new("public/country_img/world_map.png")
      send_data img.to_blob, type: 'image/jpeg', disposition: 'inline'
      return
    end
    if params[:game_num]=="1"
      if game.image1 == nil
        img = Magick::ImageList.new("public/country_img/world_map.png")
        send_data img.to_blob, type: 'image/jpeg', disposition: 'inline'
      else
        send_data game.image1, type: 'image/jpeg', disposition: 'inline'
      end
    else #==game2==
      if game.image2 == nil
        img = Magick::ImageList.new("public/country_img/world_map.png")
        send_data img.to_blob, type: 'image/jpeg', disposition: 'inline'
      else
        send_data game.image2, type: 'image/jpeg', disposition: 'inline'
      end
    end
    puts "データ送りましたーーー{#{params[:game_num]}}"
  end

  def top
    #action:proccess経由で来た時は、params[]を持っている
    #画像の拡大・縮小・移動情報を保持するため
    @register = params[:register]
    @top = params[:top]
    @left = params[:left]
    @width = params[:width]
    @height = params[:height]
    @country = params[:country] #管理モードからデータを変更した際の該当国
    @capital = params[:capital] #管理モードからデータを変更した際の該当首都
    @ClearGame1 = "" #game1のクリア国を格納(場所➡国名)
    @ClearGame2 = "" #game2のクリア国を格納(国名➡首都)

    #Gameテーブルからログインユーザーのクリア状況を取得
    if logged_in?
      game = Game.find_by(user_id: current_user.id)
      puts "ログインユーザーだから、DB問い合わせ！！user_id:#{current_user.id} game:#{game}"
      if game!=nil #データがあるなら値をセット
        puts "値取得開始"
        @ClearGame1 = game.country
        @ClearGame2 = game.capital
        puts "値ゲット：game1=>#{@ClearGame1} game2:=>#{@ClearGame2}"
      end
      puts "ログインユーザーだから、ゲーム画面へ！！user_id:#{current_user.id}"
    else
      redirect_to login_path
    end
  end
  
  #ソートメソッド
  # def batch_skelton()
  #   data = []
  #   File.open($filepath, mode = "rt"){|f|
  #     f.each_line{|line|
  #       data << line
  #     }
  #   }
  #   temp = ""
  #   for i in 0..data.length-1 do
  #     for j in i+1..data.length-1 do
  #       if(data[i].downcase > data[j].downcase)
  #         temp = data[i]
  #         data[i] = data[j]
  #         data[j] = temp
  #       end
  #     end
  #   end
  #   File.open("public/country_new.txt", "w") do |f|
  #     data.each do |line|
  #       f.puts(line)
  #       test = line.split("/")
  #       puts "#{test[0]}"
  #     end
  #   end
  #   redirect_to '/'
  # end

  #country.txtにinsert_strを追加書き込み
  #country.txtはソート済み
  #insert_strを正しい位置へ差し込む
  def insert_data(insert_str)
    origin_data = []
    # country.txt読み込み
    File.open($filepath, mode = "rt"){|f|
      f.each_line{|line|
      origin_data << line
      }
    }
    #配列に挿入（ソートされた位置へ）
    for i in 0..origin_data.length-1 do
        if(origin_data[i].downcase > insert_str)
          origin_data.insert(i, insert_str) #origin_dataのi番目とi+1番目の間に要素を挿入
          break
        end
    end
    #ファイル作成（上書き）
    File.open($filepath, "w") do |f|
      origin_data.each do |line|
        f.puts(line)
        test = line.split("/")
        puts "#{test[0]}"
      end
    end
  end

  #画像透明化のバッチ処理アクション
  # def batch_skelton()
  #   #================================================
  #   # input_dir = "public/country_region/" #入力フォルダ
  #   # output_dir = "public/skelton_image/" #出力フォルダ
  #   input_dir = "public/入力フォルダ/" #入力フォルダ
  #   output_dir = "public/出力フォルダ/" #出力フォルダ
  #   #================================================
  #   if params[:skelton]==nil
  #     redirect_to '/'
  #     return
  #   end
  #   files = []
  #   files = list_files(input_dir)
  #   completed=0
  #   start_time = Time.now
  #   files.each do |filename|
  #     puts "進行状況：#{completed}/#{files.length}(#{completed*100/files.length}%)"
  #     img = Magick::Image.read("#{input_dir}/#{filename}").first
  #     # skelton_image(img)
  #     image_color_change(img)
  #     img = img.matte_floodfill(0, 0)
  #     img.write("#{output_dir}#{filename}")
  #     img.destroy! # メモリ解放
  #     completed += 1
  #   end
  #   sec = Time.now - start_time
  #   day = sec.to_i / 86400
  #   timer = (Time.parse("1/1") + (sec - day * 86400)).strftime("#{day}日%H時間%M分%S秒")
  #   puts "進行状況：#{files.length}/#{files.length}(100%)"
  #   puts "----------------------------------"
  #   puts "バッチ処理完了"
  #   puts "入力フォルダ：#{input_dir}"
  #   puts "出力フォルダ：#{output_dir}"
  #   puts "処理ファイル数：#{files.length}"
  #   puts "処理時間：#{timer}"
  #   puts "----------------------------------"
  #   redirect_to '/'
  # end
 
  #ディレクトリ以下のファイルを取得
  def list_files(dirpath)
    fileplace = []
    Dir.foreach(dirpath) do |file| #dirpath以下のファイルを取得
      if file.include?(".png") #png拡張子のみ取得
        fileplace << file
      end
    end
    return fileplace
  end

  #緑の領域以外を透明にする関数
  #緑の領域以外の場所を全て青色で塗った後、青を全て透明にする
  def skelton_image(img)
    img.columns.to_i.times do |x|
      img.rows.to_i.times do |y|
        unless img.export_pixels(x,y,1,1)[0].to_i == 0 \
            && img.export_pixels(x,y,1,1)[1].to_i == 65535
            img.pixel_color(x,y,Magick::Pixel.new(0,0,65535))
        end
      end
    end
  end

  #緑の領域を別の色に変更
  def image_color_change(img)
    img.columns.to_i.times do |x|
      img.rows.to_i.times do |y|
        if img.export_pixels(x,y,1,1)[0].to_i == 0 \
            && img.export_pixels(x,y,1,1)[1].to_i == 65535
            img.pixel_color(x,y,Magick::Pixel.new(0,0,65535))
        else
            img.pixel_color(x,y,Magick::Pixel.new(0,65535,0))
        end
      end
    end
  end

  def proccess
    if params[:position]==nil
      return
    end
    # ビューに返すインスタンス変数
    @top = params[:top]
    @left = params[:left]
    @width = params[:width]
    @height = params[:height]
    @country = params[:country]
    @capital = params[:capital]
    @region = params[:region]
    @register = true # ビューの登録モードON
    
    img = Magick::Image.read('public/country_img/world_map.png').first
    green_skelton = Magick::Image.read('public/country_img/skelton.png').first
    blue_skelton = Magick::Image.read('public/country_img/skelton.png').first
    #---------------------------------------------------
    #ビューから座標を受け取る｛例｝x1,y1,x2,y2,x3,y3...
    array = params[:position].split(",")
    pos_arr = []
    x = 0
    (array.length/2).times do |i| #2要素ずつ取得して配列にする
      pos_arr << [array[i+x].to_i, array[i+x+1].to_i]
      x += 1
    end
    #---------------------------------------------------
    country_pos = []
    pix_check(pos_arr, img,country_pos,green_skelton,blue_skelton) # 境界線で囲まれた領域を緑で塗る

    img = img.matte_floodfill(664, 1053) #デバッグ
    img = img.matte_floodfill(693, 1009) #デバッグ
    img = img.matte_floodfill(686, 1058) #デバッグ
    img.write("public/world.png") # デバッグ

    puts "境界線で囲まれた領域を緑で塗る"
    green_skelton.write("public/country_img/green/#{@country}.png") # 画像保存
    puts "緑画像の背景透過・保存"
    blue_skelton.write("public/country_img/blue/#{@country}.png") # 画像保存
    puts "青画像の背景透過・保存"
    insert_data(@country.to_s + "/" + @capital.to_s + "/" + @region.to_s + "/" + country_pos.to_s)
    puts "国データテキストの保存"
    t=Time.new
    time_str = t.strftime("%Y-%m-%d %H:%M:%S") # 時間を文字列に変換
    File.open("public/history.txt", "a") do |f|
      f.puts(time_str + " " + @country.to_s + "を追加しました．")
    end
    puts "履歴ファイルの保存"
    #以下のコードはURLにパラメータが付加される．管理モード時しかこのアクションは使用しないため、問題ないはず．．．
    redirect_to :controller => 'home', :action => 'top', 
                                                         :top => params[:top], :left => params[:left], :width => params[:width], 
                                                         :height => params[:height], :country => params[:country], 
                                                         :capital => params[:capital], :register => @register
    img.destroy! # メモリ解放
    green_skelton.destroy! # メモリ解放
    blue_skelton.destroy! # メモリ解放
  end
  
  # 近傍画素チェック＆描画
  def pix_check(array, img, country_pos,green_skelton,blue_skelton)
    #==============================================
    #img => 境界線情報が乗っている世界地図
    #green_skelton => 透明なキャンバス.緑画像を作成用
    #blue_skelton => 透明なキャンバス.青画像を作成用
    #==============================================
    # array = [[col,row]] #2次元配列で定義
    temp=[] #あとで2次元配列で使う
    search_px = 0
    draw_px = 0
    #=============================================
    #境界線のR値は42405
    #フィンランドの境界線に43176があるため、補完
    #=============================================
    start_time = Time.now
    while array.length > 0 do
      puts "array_length:#{array.length}"
      array.each do |arr|
        # 左
        if (arr[0]-1 >= 0) && (arr[1] >= 0) # 調べる座標がマイナスなら調べない
          if img.export_pixels(arr[0]-1,arr[1],1,1)[0].to_i != 42405 \
              && img.export_pixels(arr[0]-1,arr[1],1,1)[0].to_i != 43176 \
                    && img.export_pixels(arr[0]-1,arr[1],1,1)[1].to_i != 65535
            img.pixel_color(arr[0]-1,arr[1],Magick::Pixel.new(0,65535,0))
            green_skelton.pixel_color(arr[0]-1,arr[1],Magick::Pixel.new(0,65535,0))
            blue_skelton.pixel_color(arr[0]-1,arr[1],Magick::Pixel.new(0,0,65535))
            temp<<[arr[0]-1,arr[1]]
            puts "左"
          end
        end
        # 上
        if (arr[0] >= 0) && (arr[1]-1 >= 0)
          if img.export_pixels(arr[0],arr[1]-1,1,1)[0].to_i != 42405 \
              && img.export_pixels(arr[0],arr[1]-1,1,1)[0].to_i != 43176 \
                    && img.export_pixels(arr[0],arr[1]-1,1,1)[1].to_i != 65535
            img.pixel_color(arr[0],arr[1]-1,Magick::Pixel.new(0,65535,0))
            green_skelton.pixel_color(arr[0],arr[1]-1,Magick::Pixel.new(0,65535,0))
            blue_skelton.pixel_color(arr[0],arr[1]-1,Magick::Pixel.new(0,0,65535))
            temp<<[arr[0],arr[1]-1]
            puts "上"
          end
        end
        # 右
        if (arr[0]+1 >= 0) && (arr[1] >= 0)
          if img.export_pixels(arr[0]+1,arr[1],1,1)[0].to_i != 42405 \
              && img.export_pixels(arr[0]+1,arr[1],1,1)[0].to_i != 43176 \
                    && img.export_pixels(arr[0]+1,arr[1],1,1)[1].to_i != 65535
            img.pixel_color(arr[0]+1,arr[1],Magick::Pixel.new(0,65535,0))
            green_skelton.pixel_color(arr[0]+1,arr[1],Magick::Pixel.new(0,65535,0))
            blue_skelton.pixel_color(arr[0]+1,arr[1],Magick::Pixel.new(0,0,65535))
            temp<<[arr[0]+1,arr[1]]
            puts "右"
          end
        end
        # 下
        if (arr[0] >= 0) && (arr[1]+1 >= 0)
          if img.export_pixels(arr[0],arr[1]+1,1,1)[0].to_i != 42405 \
              && img.export_pixels(arr[0],arr[1]+1,1,1)[0].to_i != 43176 \
                    && img.export_pixels(arr[0],arr[1]+1,1,1)[1].to_i != 65535
            img.pixel_color(arr[0],arr[1]+1,Magick::Pixel.new(0,65535,0))
            green_skelton.pixel_color(arr[0],arr[1]+1,Magick::Pixel.new(0,65535,0))
            blue_skelton.pixel_color(arr[0],arr[1]+1,Magick::Pixel.new(0,0,65535))
            temp<<[arr[0],arr[1]+1]
            puts "下"
          end
        end
        search_px += 4
      end
      array = temp
      if temp !=[]
        country_pos << temp #塗った座標を全部記録
      end
      draw_px += temp.length
      temp=[]
    end
    puts "============================"
    puts "検索した画素数：#{search_px}"
    puts "塗った画素数：#{draw_px}(#{Math.sqrt(draw_px).to_i}x#{Math.sqrt(draw_px).to_i})"
    puts "処理時間：#{Time.now-start_time}秒"
    puts "============================"
  end

  # 国データを削除する
  def remove_country
    if params[:country]==nil
      redirect_to '/'
      return
    end
    @register = true # ビューの登録モードON
    @delete_country = params[:country]
    write_data = []
    File.open($filepath, mode = "rt"){|f|
      f.each_line{|line|
        arr = line.split("/")
        if arr[0] == @delete_country
          # 削除データ
        else
          # 削除対象外のデータ
          write_data << line # 書き込むデータを配列にする
        end
      }
    }
    File.open($filepath, "w") do |f|
      write_data.each do |line|
        f.puts(line)
      end
    end
    File.delete("public/country_img/green/#{@delete_country}.png") # 削除対象国の画像ファイル削除
    File.delete("public/country_img/blue/#{@delete_country}.png") # 削除対象国の画像ファイル削除
    puts "#{@delete_country}に関するデータを削除しました"

    t=Time.new
    time_str = t.strftime("%Y-%m-%d %H:%M:%S") # 時間を文字列に変換
    File.open("public/history.txt", "a") do |f|
      f.puts(time_str + " " + @delete_country.to_s + "を削除しました．")
    end
    # ビュー
    # redirect_to '/'
    #以下のコードはURLにパラメータが付加される．管理モード時しかこのアクションは使用しないため、問題ないはず．．．
    redirect_to :controller => 'home', :action => 'top', :register => @register
  end

  #テスト
  def UpdateDB
    puts "UpdateDB実行：#{params[:correct_country]}:番号：#{params[:game]}"

    if logged_in?
      puts "ログインしてるから、DB登録しとくねー(^▽^)/"
      game = Game.find_by(user_id: current_user.id) #ログインユーザーのレコードがGAMEテーブルにあるか．
      if game == nil
        #current_user.idさんはデータ初登録
        game = Game.new
        game.user_id = current_user.id
        if params[:game]=="1" #==game1==
          game.country = params[:correct_country]
          merge_1(game,params[:correct_country])
          game.save
          puts "ゲーム１クリア情報更新(新規データ)：#{game.country}"
        else #==game2==
          game.capital = params[:correct_country]
          merge_2(game,params[:correct_country])
          game.save
          puts "ゲーム２クリア情報更新(新規データ)：#{game.capital}"
        end
      else
        #データに上書きする
        if params[:game]=="1" #==game1==
          if game.country != nil
            game.country = game.country + "," + params[:correct_country]
            merge_1(game,params[:correct_country])
            game.save
          else
            game.country = params[:correct_country]
            merge_1(game,params[:correct_country])
            game.save
          end
          puts "ゲーム１クリア情報更新：#{game.country}"
        else #==game2==
          if game.capital != nil
            game.capital = game.capital + "," + params[:correct_country]
            merge_2(game,params[:correct_country])
            game.save
          else
            game.capital = params[:correct_country]
            merge_2(game,params[:correct_country])
            game.save
          end
          puts "ゲーム２クリア情報更新：#{game.capital}"
        end
      end
    end
  end

  # 画像を合成して、バイナリデータにして、DBに登録(game1用)
  def merge_1(game,clear_c)
    if game.image1 == nil
      imageListFrom = Magick::ImageList.new("public/country_img/world_map.png")
    else
      imageListFrom = Magick::Image.from_blob(game.image1).shift #DBから取得したバイナリを読込
    end
    imageListFrame = Magick::ImageList.new("public/country_img/green/#{clear_c}.png")
    imageList = imageListFrom.composite(imageListFrame, 0, 0, Magick::OverCompositeOp) #画像合成
    game.image1 = imageList.to_blob #バイナリをDBへ保存
    puts "メモリ解放開始！merge_1"
    imageListFrom.destroy!
    imageListFrame.destroy!
    imageList.destroy!
    puts "メモリ解放完了！merge_1"
  end
  # 画像を合成して、バイナリデータにして、DBに登録(game2用)
  def merge_2(game,clear_c)
    if game.image2 == nil
      imageListFrom = Magick::ImageList.new("public/country_img/world_map.png")
    else
      imageListFrom = Magick::Image.from_blob(game.image2).shift #DBから取得したバイナリを読込
    end
    imageListFrame = Magick::ImageList.new("public/country_img/green/#{clear_c}.png")
    imageList = imageListFrom.composite(imageListFrame, 0, 0, Magick::OverCompositeOp) #画像合成
    game.image2 = imageList.to_blob #バイナリをDBへ保存
    puts "メモリ解放開始！merge_2"
    imageListFrom.destroy!
    imageListFrame.destroy!
    imageList.destroy!
    puts "メモリ解放完了！merge_2"
  end
end
