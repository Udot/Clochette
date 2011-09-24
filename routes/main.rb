class MyApp < Sinatra::Application
  get '/mu-c9478619-b3ea1fef-e218a7ee-09081759' do
    '42'
  end
  get "/?:category?/?:offset?" do
    @active = "root"
    cat = params[:category] || "all"
    offset = params[:offset].to_i
    offset = 0 if offset == nil || offset < 0
    @offset = offset
    @category = cat
    @articles = NyTimes.news_wire(cat,offset)
    haml :landing
  end

  get "/about" do
    @active = "about"
    haml :about
  end

  get "/contact" do
    @active = "contact"
    haml :contact
  end
end
