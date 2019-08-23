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
    @mindmap.nodes.destroy_all
    params['mindmap']['nodes'].each do |nod|
      @mindmap.nodes << Node.create(title: nod[:title], left: nod[:left], top: nod[:top])
    end if params['mindmap']['nodes'].present?
    @mindmap.connections.destroy_all
    params['mindmap']['connections'].each do |con|
      @mindmap.connections << Connection.create(parent_x: con[:parent_x], parent_y: con[:parent_y], child_x: con[:child_x], child_y: con[:child_y])
    end if params['mindmap']['connections'].present?
    respond_to do |format|
      format.json { render json: {mindmap: mindmap_as_json(@mindmap)}}
      format.html { }
    end
  end

  def update
    @mindmap.update(mindmap_params)
    @mindmap.nodes.destroy_all
    params['mindmap']['nodes'].each do |nod|
      @mindmap.nodes << Node.create(title: nod[:title], left: nod[:left], top: nod[:top])
    end if params['mindmap']['nodes'].present?
    @mindmap.connections.destroy_all
    params['mindmap']['connections'].each do |con|
      @mindmap.connections << Connection.create(parent_x: con[:parent_x], parent_y: con[:parent_y], child_x: con[:child_x], child_y: con[:child_y])
    end if params['mindmap']['connections'].present?
    respond_to do |format|
      format.json { render json: {mindmap: mindmap_as_json(@mindmap)}}
      format.html { }
    end
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
    params.require(:mindmap).permit(:name)
  end
end
