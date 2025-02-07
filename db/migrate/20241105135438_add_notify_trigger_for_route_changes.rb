class AddNotifyTriggerForRouteChanges < ActiveRecord::Migration[7.2]
  def up
    execute <<-SQL
      CREATE OR REPLACE FUNCTION notify_event() RETURNS TRIGGER AS $$
        BEGIN
          PERFORM pg_notify('notify', NOW()::text);
          RETURN NULL;
        END;
      $$ LANGUAGE plpgsql;
    SQL

    execute <<-SQL
      CREATE TRIGGER routes_notify_event
      AFTER INSERT OR UPDATE OR DELETE ON routes
      FOR EACH ROW EXECUTE PROCEDURE notify_event();
    SQL

    execute <<-SQL
      CREATE TRIGGER users_notify_event
      AFTER INSERT OR UPDATE OR DELETE ON users
      FOR EACH ROW EXECUTE PROCEDURE notify_event();
    SQL
  end

  def down
    execute <<-SQL
      DROP TRIGGER IF EXISTS routes_notify_event ON routes;
    SQL

    execute <<-SQL
      DROP TRIGGER IF EXISTS users_notify_event ON users;
    SQL

    execute <<-SQL
      DROP FUNCTION IF EXISTS notify_event();
    SQL
  end
end
