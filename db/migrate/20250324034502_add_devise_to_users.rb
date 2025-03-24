# frozen_string_literal: true

class AddDeviseToUsers < ActiveRecord::Migration[7.1]
  def self.up
    # 既にDeviseCreateUsersマイグレーションでカラムが追加されているため、
    # このマイグレーションでは何も行わない
    # 空のマイグレーションとして残しておく
  end

  def self.down
    # By default, we don't want to make any assumption about how to roll back a migration when your
    # model already existed. Please edit below which fields you would like to remove in this migration.
    raise ActiveRecord::IrreversibleMigration
  end
end
