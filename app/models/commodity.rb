class Commodity < ActiveRecord::Base
  belongs_to :detail, polymorphic: true
  belongs_to :catalog
  has_many :prices, dependent: :destroy
  has_many :import_files, as: :symbol, dependent: :destroy
  has_many :collections, dependent: :destroy

  CATEGORY = {stamp: "邮票", coin: '硬币', bill: '纸钞'}
  IS_SHOW = {true => '是',false => '否'}

  def all_name
    all_name = self.name + "-" + self.short_name + "-" + self.common_name
  end
end
