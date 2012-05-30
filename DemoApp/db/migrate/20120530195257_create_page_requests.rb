class CreatePageRequests < ActiveRecord::Migration
  def change
    create_table :page_requests do |t|
      t.string :status
      t.string :http_method
      t.string :path
      t.string :http_format
      t.string :controller_name
      t.string :action_name
      t.float :view_runtime
      t.float :db_runtime
      t.float :duration

      t.timestamps
    end
  end
end
