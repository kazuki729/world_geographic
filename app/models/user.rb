class User < ApplicationRecord
    before_save { self.email = email.downcase } #メールの一意性を保証（全て小文字で保存）
    validates :name,  presence: true, length: { maximum: 50 } #存在性：空白はダメ
    VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-]+(\.[a-z\d\-]+)*\.[a-z]+\z/i
    validates :email, presence: true, length: { maximum: 255 },
                      format: { with: VALID_EMAIL_REGEX },
                      uniqueness: { case_sensitive: false }
    has_secure_password #bycrypt-gemでpassword,password_confirmationを保持
    validates :password, presence: true, length: { minimum: 6 }, allow_nil: true #長さ制限

    # 渡された文字列のハッシュ値を返す
    def User.digest(string)
        cost = ActiveModel::SecurePassword.min_cost ? BCrypt::Engine::MIN_COST : BCrypt::Engine.cost
        BCrypt::Password.create(string, cost: cost)
    end
end
