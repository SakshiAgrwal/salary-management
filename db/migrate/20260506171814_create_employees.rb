class CreateEmployees < ActiveRecord::Migration[7.1]
  def change
    create_table :employees do |t|
      t.string :full_name
      t.string :job_title
      t.string :country
      t.decimal :salary, precision: 10, scale: 2
      t.string :email
      t.string :phone

      t.timestamps
    end
  end
end
