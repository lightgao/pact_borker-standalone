# For Bundler.with_clean_env
require 'bundler/setup'

APPLICATION_NAME = "pact-broker"
VERSION = "1.9.0"
NATIVE_GEMS = ["blockenspiel-0.4.5", "eventmachine-1.0.8", "json-1.8.3", "mysql2-0.4.1", "nokogiri-1.6.6.2", "pg-0.18.3", "redcarpet-3.3.3", "sqlite3-1.3.11", "thin-1.6.4"]

TARGETS = ["linux-x86", "linux-x86_64"]
TRAVELING_RUBY_VERSION = "20151021-2.2.2"

TARGETS.each do |target|
  namespace target do
    desc "Package #{APPLICATION_NAME} #{VERSION} for #{target}"
    task :package => [:bundle_install, :download_runtime_and_native_extension] do
      create_package("#{target}", NATIVE_GEMS)
    end

    desc "Download ruby runtime & native extension for #{target}"
    task :download_runtime_and_native_extension do
      Rake::Task["packaging/traveling-ruby-#{TRAVELING_RUBY_VERSION}-#{target}.tar.gz"].invoke
      NATIVE_GEMS.each do |gem_name_and_version|
        Rake::Task["packaging/traveling-ruby-#{TRAVELING_RUBY_VERSION}-#{target}-#{gem_name_and_version}.tar.gz"].invoke
      end
    end

    file "packaging/traveling-ruby-#{TRAVELING_RUBY_VERSION}-#{target}.tar.gz" do
      download_runtime("#{target}")
    end

    NATIVE_GEMS.each do |gem_name_and_version|
      file "packaging/traveling-ruby-#{TRAVELING_RUBY_VERSION}-#{target}-#{gem_name_and_version}.tar.gz" do
        download_native_extension("#{target}", "#{gem_name_and_version}")
      end
    end
  end
end

desc "Install gems to local directory"
task :bundle_install do
  if RUBY_VERSION !~ /^2\.2\./
    abort "You can only 'bundle install' using Ruby 2.2.x, because that's what Traveling Ruby uses."
  end

  sh "rm -rf packaging/tmp"
  sh "mkdir packaging/tmp"
  sh "cp #{APPLICATION_NAME}/#{VERSION}/Gemfile #{APPLICATION_NAME}/#{VERSION}/Gemfile.lock packaging/tmp/"

  Bundler.with_clean_env do
    sh "cd packaging/tmp && env BUNDLE_IGNORE_CONFIG=1 bundle install --path ../vendor --without development"
  end

  sh "rm -rf packaging/tmp"
  sh "rm -f packaging/vendor/*/*/cache/*"
  sh "rm -rf packaging/vendor/ruby/*/extensions"
  sh "find packaging/vendor/ruby/*/gems -name '*.so' | xargs rm -f"
  sh "find packaging/vendor/ruby/*/gems -name '*.bundle' | xargs rm -f"
  sh "find packaging/vendor/ruby/*/gems -name '*.o' | xargs rm -f"
end

def download_runtime(target)
  sh "cp ../traveling-ruby/linux/traveling-ruby-#{TRAVELING_RUBY_VERSION}-#{target}.tar.gz packaging/"
  # sh "cd packaging && curl -L -O --fail " +
  #   "http://d6r77u77i8pq3.cloudfront.net/releases/traveling-ruby-#{TRAVELING_RUBY_VERSION}-#{target}.tar.gz"
end

def download_native_extension(target, gem_name_and_version)
  sh "cp ../traveling-ruby/linux/traveling-ruby-gems-#{TRAVELING_RUBY_VERSION}-#{target}/#{gem_name_and_version}.tar.gz packaging/traveling-ruby-#{TRAVELING_RUBY_VERSION}-#{target}-#{gem_name_and_version}.tar.gz"
  # sh "curl -L --fail -o packaging/traveling-ruby-#{TRAVELING_RUBY_VERSION}-#{target}-#{gem_name_and_version}.tar.gz " +
  #   "http://d6r77u77i8pq3.cloudfront.net/releases/traveling-ruby-gems-#{TRAVELING_RUBY_VERSION}-#{target}/#{gem_name_and_version}.tar.gz"
end

def create_package(target, gems)
  package_name = "#{APPLICATION_NAME}-#{VERSION}-#{target}"
  package_dir = "output/#{package_name}"
  sh "rm -rf #{package_dir}"
  sh "mkdir -p #{package_dir}"

  sh "mkdir -p #{package_dir}/lib/app"
  # sh "cp packaging/config.ru #{package_dir}/lib/app/"
  sh "cp packaging/config.ru #{package_dir}/"

  sh "mkdir #{package_dir}/lib/ruby"
  sh "tar -xzf packaging/traveling-ruby-#{TRAVELING_RUBY_VERSION}-#{target}.tar.gz -C #{package_dir}/lib/ruby"

  sh "cp packaging/wrapper.sh #{package_dir}/#{APPLICATION_NAME}"

  sh "cp -pR packaging/vendor #{package_dir}/lib/"
  sh "cp #{APPLICATION_NAME}/#{VERSION}/Gemfile #{APPLICATION_NAME}/#{VERSION}/Gemfile.lock #{package_dir}/lib/vendor/"
  sh "mkdir #{package_dir}/lib/vendor/.bundle"
  sh "cp packaging/bundler-config #{package_dir}/lib/vendor/.bundle/config"
  gems.each do |gem_name_and_version|
    sh "tar -xzf packaging/traveling-ruby-#{TRAVELING_RUBY_VERSION}-#{target}-#{gem_name_and_version}.tar.gz " +
      "-C #{package_dir}/lib/vendor/ruby"
  end

  sh "cd output && tar -czf #{package_name}.tar.gz #{package_name}"
  sh "rm -rf #{package_dir}"
end

