generate('devise:install')
if @devise
  if yes? "create devise user? (y/N)", :blue
    @devise_model = ask_with_default "devise user", :blue, 'user'
    generate("devise", @devise_model)
  end
end
