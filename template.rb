RAILS_REQUIREMENT = "~> 5.2.0".freeze

def startup_template!
  assert_minimum_rails_version
  assert_valid_options
  assert_postgresql
  add_template_repository_to_source_path

  @gemset = ask_with_default 'rvm gemset name', :blue, app_name
  @port = ask_with_default "server dev port", :blue, 1234 
  @database_name = ask_with_default "database name", :blue, app_name
  @email = ask_with_default "email", :blue, 'weirongxu.raidou@gmail.com'
  @devise = yes? "use devise? (y/N)", :blue
  @omniauth = yes? "use omniauth? (y/N)", :blue

  apply "templates/gemfile.rb"
  template ".ruby-version.tt"
  template ".ruby-gemset.tt"

  after_bundle do
    apply_template!
  end
end

def apply_template!
  copy_file ".pryrc"

  generate("annotate:install")
  generate("simple_form:install --bootstrap")
  generate("browser_warrior:install")

  apply "templates/guard.rb"
  apply "templates/rspec.rb"
  apply "templates/devise.rb" # after rspec
  apply "templates/omniauth.rb" # after devise
  copy_file "Capfile"
  apply "templates/capistrano.rb"
  apply "templates/app.rb"
  apply "templates/config.rb"

  # directory
  directory "db"
  directory "lib"

  # env
  template ".env-example.tt"
  rails_command "init:env"
  append_to_file('.gitignore', '/.env')

  apply "templates/create-db.rb" if yes? "create database #{@database_name}? (y/N)", :red
end

require "fileutils"
require "shellwords"

# Add this template directory to source_paths so that Thor actions like
# copy_file and template resolve against our source files. If this file was
# invoked remotely via HTTP, that means the files are not present locally.
# In that case, use `git clone` to download them to a local temporary dir.
def add_template_repository_to_source_path
  if __FILE__ =~ %r{\Ahttps?://}
    require "tmpdir"
    source_paths.unshift(tempdir = Dir.mktmpdir("rails-template-"))
    at_exit { FileUtils.remove_entry(tempdir) }
    git clone: [
      "--quiet",
      "https://github.com/weirongxu/rails-template.git",
      tempdir
    ].map(&:shellescape).join(" ")

    if (branch = __FILE__[%r{rails-template/(.+)/template.rb}, 1])
      Dir.chdir(tempdir) { git checkout: branch }
    end
  else
    source_paths.unshift(File.dirname(__FILE__))
  end
end

def assert_minimum_rails_version
  requirement = Gem::Requirement.new(RAILS_REQUIREMENT)
  rails_version = Gem::Version.new(Rails::VERSION::STRING)
  return if requirement.satisfied_by?(rails_version)

  prompt = "This template requires Rails #{RAILS_REQUIREMENT}. "\
           "You are using #{rails_version}. Continue anyway?"
  exit 1 if no?(prompt)
end

# Bail out if user has passed in contradictory generator options.
def assert_valid_options
  valid_options = {
    skip_gemfile: false,
    skip_bundle: false,
    skip_git: false,
    skip_test_unit: false,
    edge: false
  }
  valid_options.each do |key, expected|
    next unless options.key?(key)
    actual = options[key]
    unless actual == expected
      fail Rails::Generators::Error, "Unsupported option: #{key}=#{actual}"
    end
  end
end

def insert_before_end(path, &block)
  insert_into_file(path, "\n" + block.call, {before: /\nend/})
end

def assert_postgresql
  return if IO.read("Gemfile") =~ /^\s*gem ['"]pg['"]/
  fail Rails::Generators::Error,
       "This template requires PostgreSQL, "\
       "but the pg gem isn’t present in your Gemfile."
end

# Mimic the convention used by capistrano-mb in order to generate
# accurate deployment documentation.
def capistrano_app_name
  app_name.gsub(/[^a-zA-Z0-9_]/, "_")
end

def git_repo_url
  @git_repo_url ||=
    ask_with_default("What is the git remote URL for this project?", :blue, "skip")
end

def production_hostname
  @production_hostname ||=
    ask_with_default("Production hostname?", :blue, "example.com")
end

def staging_hostname
  @staging_hostname ||=
    ask_with_default("Staging hostname?", :blue, "staging.example.com")
end

def gemfile_requirement(name)
  @original_gemfile ||= IO.read("Gemfile")
  req = @original_gemfile[/gem\s+['"]#{name}['"]\s*(,[><~= \t\d\.\w'"]*)?.*$/, 1]
  req && req.gsub("'", %(")).strip.sub(/^,\s*"/, ', "')
end

def ask_with_default(question, color, default)
  return default unless $stdin.tty?
  question = (question.split("?") << " [#{default}]?").join
  answer = ask(question, color)
  answer.to_s.strip.empty? ? default : answer
end

def git_repo_specified?
  git_repo_url != "skip" && !git_repo_url.strip.empty?
end

def preexisting_git_repo?
  @preexisting_git_repo ||= (File.exist?(".git") || :nope)
  @preexisting_git_repo == true
end

def any_local_git_commits?
  system("git log &> /dev/null")
end

def apply_bootstrap?
  ask_with_default("Use Bootstrap gems, layouts, views, etc.?", :blue, "no")\
    =~ /^y(es)?/i
end

def apply_capistrano?
  return @apply_capistrano if defined?(@apply_capistrano)
  @apply_capistrano = \
    ask_with_default("Use Capistrano for deployment?", :blue, "no") \
    =~ /^y(es)?/i
end

def run_with_clean_bundler_env(cmd)
  success = if defined?(Bundler)
              Bundler.with_clean_env { run(cmd) }
            else
              run(cmd)
            end
  unless success
    puts "Command failed, exiting: #{cmd}"
    exit(1)
  end
end

def run_rubocop_autocorrections
  run_with_clean_bundler_env "bin/rubocop -a --fail-level A > /dev/null || true"
end

def create_initial_migration
  return if Dir["db/migrate/**/*.rb"].any?
  run_with_clean_bundler_env "bin/rails generate migration initial_migration"
  run_with_clean_bundler_env "bin/rake db:migrate"
end

startup_template!
