run('cap install')
generate("capistrano:nginx_puma:config")
@node_version =
  if yes? 'use system node version? (y/N)'
    which_node = %x{which node}
    if not which_node.nil? and not which_node.empty?
      %x{node -v}.match(/(v\d+\.\d+\.\d+)/)[1]
    end
  end || '8.11.1'

append_to_file('config/deploy/production.rb') do
<<-EOF

set :nginx_server_name, 'localhost'
set :default_env, {
  'PATH' => "$PATH:$HOME/.nvm/versions/node/#{@node_version}/bin"
}
set :rvm_ruby_version, '#{RUBY_VERSION}@#{@gemset}'
EOF
end
