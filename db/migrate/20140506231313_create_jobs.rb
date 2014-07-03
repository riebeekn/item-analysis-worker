class CreateJobs < ActiveRecord::Migration
  def change
    create_table :jobs do |t|
      t.string :status
      t.string :worker
      t.datetime :job_start
      t.datetime :job_stop
      t.string :message
      t.string :data_file
      t.string :key_file

      t.timestamps
    end
    add_index :jobs, :status
  end
end
