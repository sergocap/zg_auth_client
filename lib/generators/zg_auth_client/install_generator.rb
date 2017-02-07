require 'rails/generators'

module ZgAuthClient
  class InstallGenerator < Rails::Generators::Base
    include Rails::Generators::Migration
    source_root File.expand_path('../templates', __FILE__)

    desc 'Setup ZgAuthClient'

    def copy_user
      copy_file 'user.rb', 'app/models/user.rb'
    end

    def copy_permission
      copy_file 'permission.rb', 'app/models/permission.rb'
    end

    def self.next_migration_number(path)
      unless @prev_migration_nr
        @prev_migration_nr = Time.zone.now.strftime("%Y%m%d%H%M%S").to_i
      else
        @prev_migration_nr += 1
      end
     @prev_migration_nr.to_s
    end

    def copy_permission_migration
      migration_template 'create_permissions.rb', 'db/migrate/create_permissions.rb'
    end
  end
end
