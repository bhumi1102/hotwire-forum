class DiscussionsController < ApplicationController
  before_action :authenticate_user!

  def index
    @discussions = Discussion.all
  end

  def new
    @discussion = Discussion.new
  end

  def create
    @discussion = Discussion.new(discussion_params)

    respond_to do |format|
      if @discussion.save
      format.html { redirect_to discussions_path, notice: "Discussion created", status: :see_other }
        #format.turbo_stream { render turbo_stream: turbo_stream.append(@discussion, "<p>Hello from controller</p>") }
      format.turbo_stream do
        render turbo_stream: turbo_stream.append("turbo_test", partial: "discussions/discussion",
          locals: { discussion: @discussion })
      end
      else
        format.html { render :new, status: :unprocessable_entity }
      end
    end
  end

  private

  def discussion_params
    params.require(:discussion).permit(:name, :pinned, :closed)
  end
end