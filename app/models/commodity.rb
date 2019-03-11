class Commodity < ActiveRecord::Base
  belongs_to :detail, polymorphic: true
  belongs_to :catalog
  has_many :prices, dependent: :destroy
  has_many :import_files, as: :symbol, dependent: :destroy
  has_many :collections, dependent: :destroy
  has_many :follows, dependent: :destroy

  CATEGORY = {stamp: "邮票", coin: '硬币', bill: '纸钞'}
  IS_SHOW = {true => '是',false => '否'}

  def all_name
    all_name = self.name + "-" + self.short_name + "-" + self.common_name
  end

  def get_collection(front_user)
    return Collection.find_by(commodity_id: self.id, front_user_id: front_user.id)
  end

  def current_price
    self.prices.blank? ? 0 : self.prices.last.price
  end

end
