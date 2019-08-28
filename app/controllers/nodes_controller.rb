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
    if @node.destroy
      delete_child_nodes Node.where(parent_node: @node.id)
      respond_to do |format|
        format.json { render json: {success: true}}
        format.html { }
      end
    else
      respond_to do |format|
        format.json { render json: {success: false}}
        format.html { }
      end
    end
  end

  private

  def delete_child_nodes nodes
    return if nodes.length == 0

    nodes.each do |nod|
      delete_child_nodes Node.where(parent_node: nod.id)
      nod.destroy
    end
  end

  def set_node
    @node = Node.find_by_id(params[:id])
  end

  def node_params
    params.require(:node).permit(:title, :position_x, :position_y, :parent_node, :mindmap_id)
  end
end
