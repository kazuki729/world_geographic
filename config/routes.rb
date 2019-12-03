Rails.application.routes.draw do
  get '/' => 'home#top'
  post '/' => 'home#top'
  get '/proccess' => 'home#top'
  post '/proccess' =>'home#proccess'
  get '/remove' =>'home#remove_country'
  post '/remove' =>'home#remove_country'
  get '/batch_skelton' =>'home#batch_skelton'
  post '/batch_skelton' =>'home#batch_skelton'
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
end
