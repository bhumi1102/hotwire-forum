class Discussion < ApplicationRecord
  belongs_to :user, default: -> { Current.user }
  belongs_to :category, counter_cache: true, touch: true 
  has_many :posts, dependent: :destroy

  has_many :users, through: :posts #all users who have posted in this discussion, not unique
  has_many :discussion_subscriptions, dependent: :destroy
  # results in this SQL: SELECT "users".* FROM "users" INNER JOIN "discussion_subscriptions" ON "users"."id" = "discussion_subscriptions"."user_id" WHERE "discussion_subscriptions"."discussion_id" = $1 AND "discussion_subscriptions"."subscription_type" = $2  [["discussion_id", 1], ["subscription_type", "optin"]] 
  has_many :optin_subscribers, -> { where(discussion_subscriptions: { subscription_type: :optin }) },
            through: :discussion_subscriptions,
            source: :user
  has_many :optout_subscribers, -> { where(discussion_subscriptions: { subscription_type: :optout }) },
            through: :discussion_subscriptions,
            source: :user

  validates :name, presence: true

  accepts_nested_attributes_for :posts

  scope :pinned_first, -> { order(pinned: :desc, updated_at: :desc) }

  # discussion.category_name
  delegate :name, prefix: :category, to: :category, allow_nil: true

  # using the shortcut version here
  broadcasts_to :category, inserts_by: :prepend
  
  # note: the below 3 after_* lines could be replaced by this broadcasts_to
  # single line. But we are doing to keep the explicit version
  # broadcasts_to "discussions"
  after_create_commit -> {broadcast_prepend_to "discussions"}
  after_update_commit -> {broadcast_replace_to "discussions"}
  after_destroy_commit -> {broadcast_remove_to "discussions"}

  def to_param
    "#{id}-#{name.downcase.to_s[0...100]}".parameterize
  end

  # all users who have made a post on this discussion + user who have opted in to watch this discussion, take away users who have opted out
  def subscribed_users
    (users + optin_subscribers).uniq - optout_subscribers
  end

  def subscription_for(user)
    return nil if user.nil?
    discussion_subscriptions.find_by(user_id: user.id)
  end

  def toggle_subscription(user)
    if subscription = subscription_for(user)
      subscription.toggle!
    elsif posts.where(user_id: user.id).any?
      discussion_subscriptions.create(user: user, subscription_type: "optout")
    else
      discussion_subscriptions.create(user: user, subscription_type: "optin")
    end
  end




end
