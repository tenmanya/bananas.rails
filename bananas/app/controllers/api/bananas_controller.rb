class Api::BananasController < ApplicationController
  def index
    render json: { yellow: true }
  end
end
