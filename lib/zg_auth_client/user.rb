require 'active_support/concern'
require 'zg_redis_user_connector'
require 'config'

module ZgAuthClient
  module User
    extend ActiveSupport::Concern

    included do
      acts_as_auth_client_user
    end

    def to_s
      fullname
    end

    def fullname
      [
        surname,
        name,
        patronymic
      ].delete_if(&:blank?).join(' ').squish
    end

    def short_name
      res = []
      res << surname
      res << "#{name.first}." if name.present?
      res << "#{patronymic.first}." if patronymic.present?

      res.join(' ')
    end

    def app_name
    end

    def check_app_name
      raise 'User#app_name should not be blank' if app_name.blank?
    end

    def get_info
      RedisUserConnector.get id
    end

    def redis_info
      get_info
    end

    def set_info(*args)
      RedisUserConnector.set id, *args
    end

    def activity_notify
      check_app_name

      set_info "#{app_name}_last_activity", Time.zone.now.to_i
    end

    def info_notify
      check_app_name

      set_info "#{app_name}_info", info_hash.to_json
    end

    def info_hash
      permissions_info.any? ? { permissions: permissions_info, url: { link: "#{Settings.app.url}/", title: I18n.t('app.title') } } : {}
    end

    def permissions_info
      permissions.map { |p| { role: p.role, info: p.context.try(:to_s) }}
    end

    def after_signed_in
      info_notify
    end

    def last_activity_at
      return nil if app_name.blank?

      seconds = instance_variable_get("@#{app_name}_last_activity").to_i

      Time.at(seconds)
    end

    module ClassMethods
      def acts_as_auth_client_user
        define_method :permissions do
          @permissions ||= ::Permission.where user_id: id
        end

        define_method(:has_permission?) do |role:, context: nil|
          context ?
            permissions.for_role(role).for_context(context).exists? :
            permissions.for_role(role).exists?
        end

        if Object.const_defined?('::Permission')
          ::Permission.available_roles.each do |role|
            define_method("#{role}?") { permissions.map(&:role).include? role }
          end
        end

      end

      def find_by(id:)
        redis_info = RedisUserConnector.get(id)

        return nil if (redis_info.nil? || redis_info.empty?)

        attributes = redis_info.merge(id: id)

        build_user attributes
      end

      private

      def is_json?(obj)
        !!JSON.parse(obj)
      rescue
        false
      end

      def build_user(attributes)
        new.tap do |user|
          attributes.each do |attribute, raw_value|
            name = "@#{attribute}"
            value = is_json?(raw_value) ? JSON.parse(raw_value) : raw_value

            user.instance_variable_set name, value

            user.define_singleton_method attribute do
              instance_variable_get name
            end
          end
        end
      end
    end
  end
end
