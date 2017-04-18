class AddAuthenticatedAndUuidToCorrespondence < ActiveRecord::Migration[5.0]
  def change
    add_column :correspondence, :uuid, :string
    add_column :correspondence, :authenticated_at, :datetime, default: nil

    add_index(:correspondence, :uuid, unique: true)
  end
end
