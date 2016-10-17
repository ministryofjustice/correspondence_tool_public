class CreateFeedback < ActiveRecord::Migration[5.0]
  def change
    create_table :feedback do |t|
      t.string :rating
      t.text :comment

      t.timestamps
    end
  end
end
