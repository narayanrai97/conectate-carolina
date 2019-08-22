class Api::V1::DevicesController < ApplicationController
  skip_before_action :verify_authenticity_token, only: [:create]

  def create
    @device = Device.create!(device_params)
    json_response(@device, :created)
  end


  private
  def device_params
    # whitelist params
   params.permit(:token)
  end
end
