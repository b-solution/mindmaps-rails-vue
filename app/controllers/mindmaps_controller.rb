class MindmapsController < ApplicationController
  def new
    respond_to do |format|
      format.html { render action: 'index' }
    end
  end

  def index; end
end
