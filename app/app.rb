# frozen_string_literal: true
require 'sinatra'
require 'slim'
require 'sqlite3'
require 'bcrypt'


enable :sessions
get('/') do
  slim(:register)
end

get('/showlogin') do
  slim(:login)
end

post("/login") do 
    username = params[:username]
    password = params[:password]

    db = SQLite3::Database.new("db/todo.db")
    db.results_as_hash = true

    result = db.execute("SELECT * FROM users WHERE username = ?", username).first

    begin
      pwdigest = result["pwdigest"]
      id = result["id"]
    rescue NoMethodError => exception
      return "Användaren finns inte"
    end

    if BCrypt::Password.new(pwdigest) == password
      session[:id] = id

      redirect("/todos")
    else
      "Fel lösen"
    end
end

get("/todos") do
  id = session[:id].to_i

  db = SQLite3::Database.new("db/todo.db")
  db.results_as_hash = true

  result = db.execute("SELECT * FROM todos WHERE user_id = ?", id)


  slim(:"todos/index", locals:{todos:result})
end

post("/todos/new") do 
  content = params[:content]
  id = session[:id]

  if(content == "")
    redirect("/todos")
  end

  db = SQLite3::Database.new("db/todo.db")
  db.execute("INSERT INTO todos (content,user_id) VALUES (?,?)", content, id)

  redirect("/todos")
end

get('/todos/:id/edit') do
  id = params[:id].to_i
  db = SQLite3::Database.new("db/todo.db")
  db.results_as_hash = true
  result = db.execute("SELECT * FROM todos WHERE id = ?",id).first
  slim(:"todos/edit", locals:{result:result})
end

post('/todos/:id/update') do
  id = params[:id].to_i
  content = params[:content]
  db = SQLite3::Database.new("db/todo.db")

  db.execute("UPDATE todos SET content=? WHERE id=?", content, id)

  redirect('/todos')
end

get('/todos/:id/delete') do
  id = params[:id].to_i
  db = SQLite3::Database.new("db/todo.db")
  
  db.execute("DELETE FROM todos WHERE id = ?", id)

  redirect('/todos')
end

post("/users/new") do
  username = params[:username]
  password = params[:password]
  password_confirm = params[:password_confirm]

  if(username == "")
    return "Du glömde användarnamnet"
  end
  if(password == "")
    return "Du glömde att skriva in ett lösenord, vilket är rekommenderat"
  end

  if password == password_confirm
    #Lägg till användare
    password_digest = BCrypt::Password.create(password)
    db = SQLite3::Database.new("db/todo.db")
    db.execute("INSERT INTO users (username, pwdigest) VALUES (?,?)", username, password_digest)
    redirect("/")
  else
    return "Lösenorden matchade inte!"
  end
end
