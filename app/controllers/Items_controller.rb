class ItemsController < ApplicationController
  before_action :set_item , only: [:show, :destroy]

def index
  @items = Item.all.order('id DESC')
end

def show
  if request.path != item_path(@item)
      redirect_to @item, status: :moved_permanently
    end
end

def new
  @item = Item.new()
end

def create
  @item = Item.new(item_params)
  if @item.save
    redirect_to root_path, notice: 'Фотография успешно добавлена!'
  else
    render 'new'
  end
end

def destroy
  @item.destroy
end


  private
  
  def set_item
    @item = Item.friendly.find(params[:id])
  end
  
  
  def item_params
    params.require(:item).permit(:title, :text, :image)
  end

end