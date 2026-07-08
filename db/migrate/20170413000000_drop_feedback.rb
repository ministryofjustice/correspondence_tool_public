class DropFeedback < ActiveRecord::Migration[7.1]
  def up
    drop_table :feedback
  end

  def down
    create_table :feedback do |t|
      t.jsonb :content
      t.timestamps
    end
  end
end
