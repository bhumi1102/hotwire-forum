class DiscussionBroadcaster 
  attr_reader :discussion

  def initialize(discussion)
    @discussion = discussion
  end

  def broadcast!
    replace_header
    move_categories if discussion.saved_change_to_category_id?
    replace_new_post_form if discussion.saved_change_to_closed?
  end

  private

  def replace_header
    discussion.broadcast_replace(partial: "discussions/header", locals: { discussion: discussion})
  end

  def move_categories
    old_category_id, new_category_id = discussion.saved_change_to_category_id

    old_category = Category.find(old_category_id)
    new_category = Category.find(new_category_id)

    # remove it from old category / insert to new category
    discussion.broadcast_remove_to(old_category)
    discussion.broadcast_prepend_to(new_category)

    # reload so that the discussions_count gets updated on broadcasts
    old_category.reload.broadcast_replace_to("categories")
    new_category.reload.broadcast_replace_to("categories")
  end

  def replace_new_post_form
    discussion.broadcast_action_to(
    discussion,
    action: "replace",
    target: "new_post_form",
    partial: "discussions/posts/form",
    locals: { post: discussion.posts.new }
    )
  end


end