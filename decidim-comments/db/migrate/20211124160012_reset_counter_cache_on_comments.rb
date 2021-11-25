class ResetCounterCacheOnComments < ActiveRecord::Migration[6.0]
  def up
    Decidim::Comments::Comment.find_each do |comment|
      comment.send(:update_votes_counter)
    end
  end

  def down; end
end
