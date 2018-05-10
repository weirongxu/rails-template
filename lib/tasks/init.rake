namespace :init do
  task :env do
    require 'securerandom'
    def render
      root = Rails.root
      secret = SecureRandom.hex(64)
      eb = ERB.new(File.read(root + '.env-example'))
      File.write(root + '.env', eb.result(binding))
    end
    render
  end
end
