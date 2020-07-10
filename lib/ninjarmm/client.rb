require 'faraday'
require 'faraday_middleware'

require_relative 'sign_request_middleware'

module NinjaRMM
  class Client
    BASE_URL = 'https://api.ninjarmm.com'.freeze


    def initialize(access_id: '', secret_key: '',
                   adapter: Faraday.default_adapter)
      @client = Faraday.new(BASE_URL) do |conn|
        conn.request :json
        conn.response :json, content_type: /\bjson$/
        conn.use SignRequestMiddleware, access_id, secret_key
        conn.adapter adapter
      end
    end

    def ping
      @client.get('v1/ping').body
    end

    def customers
      organizations
    end

    def organizations
      @client.get('v2/organizations').body
    end

    def customer(id:)
      organizations(id: id)
    end

    def organizations(id:)
      @client.get("v2/organizations /#{id}").body
    end

    def devices
      @client.get('v1/devices').body
    end

    def device(id:)
      @client.get("v1/devices/#{id}").body
    end

    def alerts
      @client.get('v1/alerts').body
    end

    def alerts_since(id:)
      @client.get("v1/alerts/since/#{id}").body
    end

    def reset_alert(id:)
      @client.delete("v1/alerts/#{id}").body
    end

    def device_scripts(id:)
      @client.get("v2/device/#{id}/scripting/options").body
    end

    def device_script_run(device_id:, uid:, id:, parameters:, run_as:)
      data = {
        type: 'ACTION',
        uid: uid,
        id: id,
        parameters: parameters,
        runAs: run_as || 'system'
      }
      @client.post("v2/device/#{device_id}/script/run", data).body
    end
  end
end