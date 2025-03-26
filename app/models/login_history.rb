class LoginHistory < ApplicationRecord
  belongs_to :user

  validates :ip_address, presence: true
  validates :user_agent, presence: true

  default_scope { order(created_at: :desc) }

  def self.create_history(user, request)
    create!(
      user: user,
      ip_address: convert_to_ipv4(request.remote_ip),
      user_agent: request.user_agent
    )
  end

  private

  def self.convert_to_ipv4(ip)
    if ip.include?(':')  # IPv6の場合
      # IPv6のローカルホストアドレス
      return '127.0.0.1' if ip == '::1'
      
      # IPv4でマップされたIPv6アドレス (例: ::ffff:192.0.2.128)
      if ip =~ /^::ffff:(\d+\.\d+\.\d+\.\d+)$/
        return $1
      end
      
      # その他のIPv6アドレスの場合は、最後の4オクテットを使用
      segments = ip.split(':')
      if segments.last =~ /^(?:\d{1,3}\.){3}\d{1,3}$/
        return segments.last
      end
      
      return '0.0.0.0'
    end
    
    ip  # すでにIPv4の場合はそのまま返す
  end
end