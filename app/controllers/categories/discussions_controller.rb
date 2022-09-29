module Categories
  class DiscussionsController < ApplicationController
    before_action :authenticate_user!
    before_action :set_category

    def index
      puts "%%%%%%%%%%%%%%%%%#{@category.to_s}"
      @discussions = @category.discussions.order(updated_at: :desc)
      puts "************************* #{@discussions}"
      render "discussions/index" #the 'normal' index view not category/discussion view
    end

    private

    def set_category
      @category = Category.find(params[:id])
    end
  end
end