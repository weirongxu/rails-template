run('cap install')
generate("capistrano:nginx_puma:config")
@node_version =
  begin
    which_node = %x{which node}
    if not which_node.nil? and not which_node.empty?
      if yes? 'use system node version? (y/N)'
        %x{node -v}.match(/(v\d+\.\d+\.\d+)/)[1]
      end
    end
  end || '8.11.1'

append_to_file('config/deploy.rb') do
<<-EOF

append :linked_files, ".env"
append :linked_dirs, "log", "tmp/pids", "tmp/cache", "tmp/sockets", "public/system", "storage"
set :logrotate_logs_keep, -> { 60 }
set :logrotate_interval, -> { 'daily' }
EOF
end

append_to_file('config/deploy/production.rb') do
<<-EOF

set :nginx_server_name, 'localhost'
set :default_env, {
  'PATH' => "$PATH:$HOME/.nvm/versions/node/#{@node_version}/bin"
}
set :rvm_ruby_version, '#{RUBY_VERSION}@#{@gemset}'
EOF
end
