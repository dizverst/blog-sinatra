require 'rubygems'
require 'sinatra'
require 'sinatra/reloader'
require 'sqlite3'

def init_db
	@db = SQLite3::Database.new 'blog.sqlite'
	@db.results_as_hash = true
end

before do
	init_db
end

configure do
	init_db 
	@db.execute 'CREATE TABLE IF NOT EXISTS Posts
	(
	  id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
	  created_date DATE NOT NULL,
	  content TEXT NOT NULL
	);'

	@db.execute 'CREATE TABLE IF NOT EXISTS Comments
	(
	  id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
	  created_date DATE NOT NULL,
	  content TEXT NOT NULL,
	  post_id INTEGER
	);'
end

get '/' do
	@results = @db.execute 'select * from Posts order by id desc'

	erb :index
end

get '/new' do
  erb :new
end

post '/new' do
	content = params[:content]

	if content.length <= 0
		@error = 'Введите текст поста!'
		return erb :new
	end

	@db.execute 'insert into Posts (content, created_date) values (?, datetime())', [content]

	sleep 3
	redirect '/'
end

get '/details/:post_id' do
	post_id = params[:post_id]

	results = @db.execute 'select * from Posts where id = ?', [post_id]
	
	@row = results[0]



	erb :details
end

post '/details/:post_id' do

	post_id = params[:post_id]
	content = params[:content]

	erb "Ваш комментарий #{content} для поста #{post_id}"

	@db.execute 'insert into Comments (content, created_date, post_id) values (?, datetime(), ?)', [content, post_id]

	redirect '/details/' + post_id

end







