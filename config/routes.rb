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

  get '/UpdateDB' =>'home#UpdateDB'
  resources :users #usersに関する標準アクションが用意される
end
