Rails.application.routes.draw do
  get '/' => 'home#top'
  post '/' => 'home#top'
  get '/proccess' => 'home#top'
  post '/proccess' =>'home#proccess'
  get '/remove' =>'home#remove_country'
  post '/remove' =>'home#remove_country'
  get '/batch_skelton' =>'home#batch_skelton'
  post '/batch_skelton' =>'home#batch_skelton'
  get  '/signup',  to: 'users#new'
  post '/signup',  to: 'users#create'
  get    '/login',   to: 'sessions#new'
  post   '/login',   to: 'sessions#create'
  delete '/logout',  to: 'sessions#destroy'

  get 'image/:id/:game_num', to: 'home#image' #imgタグで画像取得用
  get '/wallpaper', to: 'home#wallpaper' #imgタグで画像取得用

  get '/UpdateDB' =>'home#UpdateDB'
  get '/RemoveDB' =>'home#RemoveDB'
  get '/ChangeLanguage' =>'home#ChangeLanguage'
  post '/PostPhoto' =>'home#PostPhoto'
  post '/UpdateCountryInfo' =>'home#UpdateCountryInfo'
  
  resources :users #usersに関する標準アクションが用意される
end
