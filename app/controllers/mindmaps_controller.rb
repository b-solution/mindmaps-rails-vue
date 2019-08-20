class MindmapsController < ApplicationController
  before_action :set_mindmap, only: [:update, :show]
  def index; end

  def new
    @mindmap = Mindmap.new(name: "Central Idea")
    respond_to do |format|
      format.json { render json: {mindmap: mindmap_as_json(@mindmap)}}
      format.html { render action: 'index' }
    end
  end

  def create
    @mindmap = Mindmap.create(mindmap_params)
    respond_to do |format|
      format.json { render json: {mindmap: mindmap_as_json(@mindmap)}}
      format.html { }
    end
  end

  def update
    
  end

  def show
    respond_to do |format|
      format.json { render json: {mindmap: mindmap_as_json(@mindmap)}}
      format.html { }
    end
  end

  private

  def set_mindmap
    @mindmap = Mindmap.find_by_id(params[:id])
  end

  def mindmap_as_json(mindmap)
    mindmap.as_json.merge(
      nodes: mindmap.nodes, 
      connections: mindmap.connections
    ).as_json
  end

  def mindmap_params
    params.require(:mindmap).permit(nodes: [], connections: [])
  end
end
