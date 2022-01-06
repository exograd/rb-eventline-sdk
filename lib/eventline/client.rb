require("net/https")
require("openssl")

module Eventline
  class Client
    PUBLIC_KEY_PIN_SET = [
      "gg3x7U4UrWfTUpYNy9wL2+GYOQhi3fg5UTn5pzA67gc="
    ].freeze

    def initialize
      store = OpenSSL::X509::Store.new
      store.add_file(File.expand_path("cacert.pem", __dir__ + "/../data"))

      @conn = Net::HTTP.new("api.eventline.net", 443)

      @conn.keep_alive_timeout = 30

      @conn.open_timeout = 30
      @conn.read_timeout = 30
      @conn.write_timeout = 30

      @conn.use_ssl = true
      @conn.verify_mode = OpenSSL::SSL::VERIFY_PEER
      @conn.cert_store = store
      @conn.verify_callback = lambda do |preverify_ok, cert_store|
        return false if !preverify_ok

        public_key = cert_store.chain.first.public_key.to_der
        fingerprint = OpenSSL::Digest::SHA256.new(public_key).base64digest
        PUBLIC_KEY_PIN_SET.include?(fingerprint)
      end
    end
  end
end
