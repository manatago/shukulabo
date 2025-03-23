Rails.application.config.middleware.use OmniAuth::Builder do
  configure do |config|
    config.path_prefix = '/auth'
  end

  provider :google_oauth2,
           ENV['GOOGLE_CLIENT_ID'],
           ENV['GOOGLE_CLIENT_SECRET'],
           {
             scope: %w[email profile],
             prompt: 'select_account',
             image_aspect_ratio: 'square',
             image_size: 50,
             access_type: 'online'
           }
end

# コールバックURLの設定
OmniAuth.config.full_host = lambda do |env|
  scheme = env['HTTPS'] == 'on' ? 'https' : 'http'
  host = env['HTTP_HOST']&.split(':')&.first || env['SERVER_NAME'] || env['SERVER_ADDR']
  port = env['SERVER_PORT']
  port = (port.to_i == 80 || port.to_i == 443) ? '' : ":#{port}"
  "#{scheme}://#{host}#{port}"
end

# 開発環境でのSSL認証スキップ（開発環境のみ）
OmniAuth.config.allowed_request_methods = [:post, :get] if Rails.env.development?