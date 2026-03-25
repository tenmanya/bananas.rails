class Api::BananasController < ApplicationController
  def index
    render json: { yellow: true, bunch: 7 }
  end
end
