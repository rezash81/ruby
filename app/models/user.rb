class User < ActiveRecord::Base
  devise :database_authenticatable, :recoverable, :rememberable, :trackable, authentication_keys: [:username]
  # :confirmable, :lockable, :timeoutable and :omniauthable, :validatable, :registerable

  validates :username, presence: {message: "نام کاربری الزامی‌ست"}, length: {minimum: 4, message: "نام کاربری باید حداقل ۴ حرف باشد"}, format: {with: /[-a-z0-9]+/, message: 'نام کاربری باید فقط حرف عدد یا خط تیره باشد.'}, uniqueness: { message: 'این نام کاربری قبلا انتخاب شده است' }
  # validate :freeze_user_type, on: :update

  %w(super_admin admin operator user).each do |type|
    define_method("#{type}?") { user_type == UConf[:user_type][type] }
    scope "#{type}s", ->{ where(user_type: UConf[:user_type][type]) }
  end


  def higher_than?(type)
    user_type >= UConf[:user_type][type.to_sym].to_i
  end

private
  def freeze_user_type
    errors.add(:user_type, "Cannot be changed") if self.user_type_changed?
  end

end
