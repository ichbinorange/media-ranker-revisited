class User < ApplicationRecord
  has_many :votes
  has_many :works
  has_many :ranked_works, through: :votes, source: :work

  validates :username, uniqueness: true, presence: true

  def work_owner(work)
    self.works.find_by(id: work)
  end

  def self.build_from_github(auth_hash)
    user = User.new
    user.uid = auth_hash["uid"]
    user.provider = auth_hash["provider"]
    user.username = auth_hash["info"]["nickname"]
    user.email = auth_hash["info"]["email"]
    return user
  end
end
