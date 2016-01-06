require 'pusher'

Pusher.app_id = '129623' #I've provided the correct app_id
Pusher.key =  '80b5913c49bad64d4921'
Pusher.secret = '2f89c7340e377d19b4b2' #I've provided the correct app_secret
Pusher.url = "https://80b5913c49bad64d4921:2f89c7340e377d19b4b2@api.pusherapp.com/apps/129623"
Pusher.logger = Rails.logger

class CommentsController < ActionController::Base
  
  prepend_before_action :get_model
  before_action :get_comment, :only => [:show, :edit, :update, :destroy]

  respond_to :html
  
  def index
    @comments = @model.comments
    respond_with([@model,@comments])
  end

  def show
    respond_with([@model,@comment])
  end

  def new
    respond_with([@model,@comment = Comment.new(:parent => params[:parent])])

    @p_id=@model.id
    Pusher.trigger(@model.id, 'comment', {
        message: @comment.text
      })  

    render :file=>'shared/ajaxcomment' , :layout=>false

  end

  def edit
    respond_with([@model,@comment])
  end

  def create
    @comment = @model.create_comment!(comment_params)
    if @comment.save
      flash[:notice] = 'Comment was successfully created.'
    else
      flash[:error] = 'Comment wasn\'t created.'
    end
    respond_with(@model)
  end

  def update
    if @comment.update_attributes(comment_params)
      flash[:notice] = 'Comment was successfully updated.'
    else
      flash[:error] = 'Comment wasn\'t deleted.'
    end
    respond_with([@model,@comment], :location => @model)
  end

  def destroy
    @comment.destroy
    respond_with(@model)
  end

  private

  def get_model
    @model = params.each do |name, value|
      if name =~ /(.+)_id$/
        break $1.classify.camelize.constantize.find(value)
      end
    end
  end
  
  def get_comment
    @comment = @model.comments.find(params[:id])
  end

  def comment_params
    params.require(:comment).permit(:text, :author)
  end

end
