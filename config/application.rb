require_relative "boot"

require "rails/all"

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

# Load dotenv only in development or test environment
if ['development', 'test'].include? ENV['RAILS_ENV']
  Dotenv::Railtie.load
end

module Shukulabo
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 7.2

    # Please, add to the `ignore` list any other `lib` subdirectories that do
    # not contain `.rb` files, or that should not be reloaded or eager loaded.
    # Common ones are `templates`, `generators`, or `middleware`, for example.
    config.autoload_lib(ignore: %w[assets tasks])

    # 日本語化対応
    config.i18n.default_locale = :ja
    config.i18n.load_path += Dir[Rails.root.join('config', 'locales', '**', '*.{rb,yml}').to_s]

    # タイムゾーンを日本時間に設定
    config.time_zone = "Asia/Tokyo"
    config.active_record.default_timezone = :local

    # ジェネレータの設定
    config.generators do |g|
      g.assets false          # CSS, JavaScriptファイルを自動生成しない
      g.helper false         # helperを自動生成しない
    end

    config.hosts << "shukulabo.kyozai.net"
  end
end
