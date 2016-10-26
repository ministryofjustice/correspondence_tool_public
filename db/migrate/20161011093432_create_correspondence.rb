class CreateCorrespondence < ActiveRecord::Migration[5.0]
  def change
    create_table :correspondence do |t|
      t.jsonb :content

      t.timestamps
    end
  end
end
