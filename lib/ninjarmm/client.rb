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

    def customers
      organizations
    end

    def organizations
      @client.get('v2/organizations').body
    end

    def customer(id:)
      organizations(id: id)
    end

    def organization(id:)
      @client.get("v2/organizations /#{id}").body
    end

    def devices
      @client.get('v2/devices').body
    end

    def devices_detailed
      @client.get('v2/devices-detailed').body
    end

    def device(id:)
      @client.get("v2/devices/#{id}").body
    end

    def alerts
      @client.get('v2/alerts').body
    end

    def reset_alert(uid:)
      @client.delete("v2/alerts/#{uid}").body
    end

    def dashboard_url(id:)
      @client.get("v2/device/#{id}/dashboard-url").body
    end

    def device_scripts(id:)
      @client.get("v2/device/#{id}/scripting/options").body
    end

    def device_script_run(device_id:, type: nil, uid:, id:, parameters: nil, run_as:)
      data = {
        type: type || (uid.blank? ? 'SCRIPT' : 'ACTION'),
        uid: uid,
        id: id,
        parameters: parameters,
        runAs: run_as
      }
      @client.post("v2/device/#{device_id}/script/run", data).body
    end

    def roles
      @client.get("v2/roles").body
    end
  end
end