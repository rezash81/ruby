class Ability
  include CanCan::Ability

  def initialize(user)
    if user
      case user.user_type
      when UConf[:user_type][:super_admin]
        can :manage, :all
      when UConf[:user_type][:admin]
        can :manage, User do |other_user|
          other_user.user_type < UConf[:user_type][:admin]
        end

        can :read, User

        can :manage, Client
        can :manage, ClientInfo

        can :manage, Sensor
      when UConf[:user_type][:operator]
        can [:read, :compare, :attachments, :live, :check_new, :archive_data, :export, :export_standard, :export_shown_data, :export_live_data], Client
        can :read, ClientInfo
        can [:update, :get_sensors, :update_sensors, :add_attachment, :set_default_attachment,
             :delete_attachment, :import_usb, :import_usb_post, :import, :import_data, :export],
            Client do |client|
          client.operator_id == user.id
        end
        can :manage, User do |other_user|
          other_user.user_type < UConf[:user_type][:operator]
        end
      when UConf[:user_type][:user]
        can [:read, :compare, :attachments, :live, :check_new, :archive_data, :export, :export_standard, :export_shown_data, :export_live_data], Client
      end
    else
      return false
    end
    # Define abilities for the passed in user here. For example:
    #
    #   user ||= User.new # guest user (not logged in)
    #   if user.admin?
    #     can :manage, :all
    #   else
    #     can :read, :all
    #   end
    #
    # The first argument to `can` is the action you are giving the user 
    # permission to do.
    # If you pass :manage it will apply to every action. Other common actions
    # here are :read, :create, :update and :destroy.
    #
    # The second argument is the resource the user can perform the action on. 
    # If you pass :all it will apply to every resource. Otherwise pass a Ruby
    # class of the resource.
    #
    # The third argument is an optional hash of conditions to further filter the
    # objects.
    # For example, here the user can only update published articles.
    #
    #   can :update, Article, :published => true
    #
    # See the wiki for details:
    # https://github.com/ryanb/cancan/wiki/Defining-Abilities
  end
end
