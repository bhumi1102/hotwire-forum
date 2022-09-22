class Discussion < ApplicationRecord
  belongs_to :user, default: -> { Current.user }

  validates :name, presence: true

  # note: the below 3 after_* lines could be replaced by this broadcasts_to
  # single line. But we are doing to keep the explicit version
  # broadcasts_to "discussions"
  after_create_commit -> {broadcast_prepend_to "discussions"}
  after_update_commit -> {broadcast_replace_to "discussions"}
  after_destroy_commit -> {broadcast_remove_to "discussions"}

  def to_param
    "#{id}-#{name.downcase.to_s[0...100]}".parameterize
  end
end
