class CreatePermissions < ActiveRecord::Migration
  def change
    create_table :permissions do |t|
      t.string :user_id
      t.string :role
      t.references :context, polymorphic: true
      t.timestamps
    end

    add_index :permissions, [:user_id, :role, :context_id, :context_type], name: 'by_user_and_role_and_context'
  end
end
