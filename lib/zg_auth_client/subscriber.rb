require 'zg_auth_redis_user_connector'
require 'daemons'

module ZgAuthClient
  class Subscriber < ::Rails::Railtie
    rake_tasks do
      namespace :subscriber do
        desc 'Start listen channel'
        task start: :environment do
          Daemons.call(app_name: 'subscriber', multiple: false, dir_mode: :normal, dir: 'tmp/pids') do
            logger = Logger.new("#{Rails.root}/log/subscriber.log")

            begin
              RedisUserConnector.sub('broadcast') do |on|
                on.subscribe    do
                  logger.info 'Subscribed to broadcast channel'
                end

                on.message      do |_, message|
                  logger.info "Recieved message about user <#{message}> signed in"
                  ::User.find_by(id: message).try :after_signed_in
                end

                on.unsubscribe  do
                  logger.info 'Unsubscribed from broadcast channel'
                end
              end
            rescue Exception => e
              logger.fatal e
            end
          end
        end

        desc 'Stop listen channel'
        task stop: :environment do
          Daemons::Monitor.find('tmp/pids', 'subscriber').try :stop
        end

        desc 'Restart subscriber'
        task restart: :environment do
          Rake::Task['subscriber:stop'].invoke
          Rake::Task['subscriber:start'].invoke
        end
      end
    end
  end
end
