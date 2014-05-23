  class Shop::TagsController < ApplicationController
    before_action :set_tag, only: [:show, :edit, :update, :destroy]

    # GET /tags
    def index
      @tags = Shop::Tag.where(account_id: session[:account_id]).order(the_order: :asc)
    end

    # GET /tags/1
    def show
    end

    # GET /tags/new
    def new
      @tag = Shop::Tag.new
      @tag.the_order = 10
      @tag.is_enabled = true
    end

    # GET /tags/1/edit
    def edit
    end

    # POST /tags
    def create
      @tag = Shop::Tag.new(tag_params)
      @tag.account_id = session[:account_id]
      if @tag.save
        redirect_to tags_url, notice: '标签已创建.'
      else
        render action: 'new'
      end
    end

    # PATCH/PUT /tags/1
    def update
      if @tag.update(tag_params)
        redirect_to tags_url, notice: '标签已更新.'
      else
        render action: 'edit'
      end
    end

    # DELETE /tags/1
    def destroy
      if @tag.products.size > 0 
        flash[:error] = '该标签有关联的产品，不能删除'
      else
        @tag.destroy
        flash[:notice] = '标签已删除.'
      end
      redirect_to tags_url
    end

    private
      # Use callbacks to share common setup or constraints between actions.
      def set_tag
        @tag = Shop::Tag.find(params[:id])
      end

      # Only allow a trusted parameter "white list" through.
      def tag_params
        params.require(:tag).permit(:name,:the_order,:is_enabled)
      end
  end