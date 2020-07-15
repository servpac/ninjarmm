require 'faraday'
require 'faraday_middleware'

require_relative 'sign_request_middleware'

module NinjaRMM
  class Client
    BASE_URL = 'https://api.ninjarmm.com'.freeze


    def initialize(access_id: '', secret_key: '', access_token: nil,
                   adapter: Faraday.default_adapter)
      @client =
        if access_token
          faraday_settings = lambda do |conn|
            conn.request :json
            #conn.response :json, content_type: /\bjson$/
            conn.adapter adapter
          end
          client = OAuth2::Client.new('', '', site: 'https://app.ninjarmm.com', connection_build: faraday_settings, raise_errors: false)
          @using_oauth = true
          OAuth2::AccessToken.new(client, access_token, expires_in: 1.hour)
        else
          Faraday.new(BASE_URL) do |conn|
            conn.request :json
            conn.response :json, content_type: /\bjson$/
            conn.use SignRequestMiddleware, access_id, secret_key
            conn.adapter adapter
          end
        end
    end

    def customers
      organizations
    end

    def organizations
      get('v2/organizations')
    end

    def customer(id:)
      organizations(id: id)
    end

    def organization(id:)
      get("v2/organizations /#{id}")
    end

    def devices
      get('v2/devices')
    end

    def devices_detailed
      get('v2/devices-detailed')
    end

    def device(id:)
      get("v2/devices/#{id}")
    end

    def alerts
      get('v2/alerts')
    end

    def reset_alert(uid:)
      delete("v2/alerts/#{uid}")
    end

    def dashboard_url(id:)
      get("v2/device/#{id}/dashboard-url")
    end

    def device_scripts(id:)
      get("v2/device/#{id}/scripting/options")
    end

    def device_script_run(device_id:, type: nil, uid:, id:, parameters: nil, run_as:)
      data = {
        type: type || (uid.blank? ? 'SCRIPT' : 'ACTION'),
        uid: uid,
        id: id,
        parameters: parameters,
        runAs: run_as
      }
      post("v2/device/#{device_id}/script/run", data)
    end

    def roles
      get("v2/roles")
    end

    protected

    %w[get delete].each do |method|
      class_eval <<-RUBY, __FILE__, __LINE__ + 1
        def #{method}(url)
          @using_oauth ? @client.#{method}(url).parsed : @client.#{method}(url).body
        end
      RUBY
    end

    %w[post put patch].each do |method|
      class_eval <<-RUBY, __FILE__, __LINE__ + 1
        def #{method}(url, body)
          @using_oauth ? @client.#{method}(url, body: body).parsed : @client.#{method}(url, body).body
        end
      RUBY
    end
  end
end