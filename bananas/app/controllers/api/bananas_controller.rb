class Api::BananasController < ApplicationController
  def index
    render json: { yellow: false }
  end
end
