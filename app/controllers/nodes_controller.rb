class NodesController < ApplicationController
  before_action :set_node, only: [:show, :edit, :update, :destroy]


  def create
    @node = Node.create(node_params)
    respond_to do |format|
      format.json { render json: {node: @node}}
      format.html { }
    end
  end

  def update
    @node.update(node_params)
    respond_to do |format|
      format.json { render json: {node: @node}}
      format.html { }
    end
  end

  def destroy
    debugger
    @node.destroy
    respond_to do |format|
      format.json { render json: {success: true}}
      format.html { }
    end
  end

  private

  def set_node
    @node = Node.find_by_id(params[:id])
  end

  def node_params
    params.require(:node).permit(:title, :position_x, :position_y, :parent_node, :mindmap_id)
  end
end
