class PostsController < ApplicationController
  before_action :authenticate_user!, except: [:index, :outbound, :submitted_by_user, :liked_by_user]
  before_action :set_date, only: [:index]
  before_action :set_post, only: [:show, :edit, :update, :destroy, :outbound, :upvote]
  before_action :set_user, only: [:submitted_by_user, :liked_by_user]

  #skip_before_action :check_user_signin

  # TODO: add pagination and infinite scroll support!
  def index
    if !params[:profile_tab].present?
      @posts = Post::Base.order('created_at DESC')

      if @date
        @posts = @posts.on_date(@date)
      end

      # if params[:tag].present?
      #   @posts = @posts.tagged_with(params[:tag])
      # end

      @posts = @posts.group_by { |p| p.created_at.to_date }
    end

    if params[:profile_tab].present? && params[:profile_tab] == 'true' && params[:type] == 'posts'
      @posts = current_user.posts.order("id DESC")
      render partial: 'posts/post', collection: @posts, locals: {profile_tab: true}, status: 200 and return
    elsif params[:profile_tab].present? && params[:profile_tab] == 'true' && params[:type] == 'upvotes'
      votes = current_user.votes.includes(:votable)
      @posts = votes.map(&:votable)
      render partial: 'posts/post', collection: @posts, locals: {profile_tab: true}, status: 200 and return
    end
  end

  def submitted_by_user
    @posts = Post::Base.where user: @user
    @posts = @posts.group_by { |p| p.created_at.to_date }
    render :index
  end

  def liked_by_user
    @posts = @user.find_up_voted_items
    render :index
  end

  def upvote
    if params[:voted] == 'false'
      current_user.up_votes(@post)
      vote = current_user.votes.last
      Activity.create!(user_id: @post.user_id, item: vote, from_user_id: current_user.id, post_id: @post.id) if current_user.id != @post.user_id
      notice = "Successfully upvoted!"
      result = { voted: true, vote_count: @post.votes_for.size }.to_json
    else
      vote = ActsAsVotable::Vote.where(voter_id: current_user.id, votable_id: @post.id).first
      ActiveRecord::Base.connection.execute("DELETE from activities where item_id = #{vote.id} and from_user_id = #{current_user.id}") if vote.present?
      vote.try(:delete)
      notice = "Successfully removed vote!"
      result = { voted: false, vote_count: @post.votes_for.size }.to_json
    end
    render json: result
    #redirect_to posts_path, notice: notice
  end

  def outbound
    @post.clicks.create! user: current_user
    redirect_to @post.url
  end

  # GET /posts/new
  def new
    @post = Post::Base.new
  end

  # POST /posts
  # POST /posts.json
  def create
    @post = Post::Link.new post_params.merge user: current_user
    respond_to do |format|
      if @post.save
        format.html { redirect_to post_comments_path(@post), notice: 'Post was successfully created.' }
        format.json { render :show, status: :created, location: post_path(@post) }
      else
        handle_post_error format, :new
      end
    end
  end

  private

  def set_date
    return unless params[:year] && params[:month] && params[:day]
    @date = Date.strptime("#{params[:year]}-#{params[:month]}-#{params[:day]}")
  end

  def handle_post_error(format, action = :edit)
    format.html { render action }
    format.json { render json: @post.errors, status: :unprocessable_entity }
  end

  def set_user
    @user = User.friendly.find(params[:user_id])
  end

  # Use callbacks to share common setup or constraints between actions.
  def set_post
    @post = Post::Base.friendly.find(params[:id])
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def post_params
    params.require(:post).permit(:title, :is_hope)
  end
end
