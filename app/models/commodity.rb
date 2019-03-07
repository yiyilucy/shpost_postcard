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

  def self.joins_stamp
    Commodity.where(detail_type: 'Stamp').joins("left join stamps on stamps.id = commodities.detail_id")
  end

  def self.with_stamp_serial_no(stamp_serial_no)
    where("stamps.serial_no like ?", "%#{stamp_serial_no}%")
  end

  def self.with_stamp_format(stamp_format)
    where(stamps: {format: stamp_format})
  end

  def self.with_stamp_theme(stamp_theme)
    where(stamps: {theme: stamp_theme})
  end

  def self.joins_coin
    Commodity.where(detail_type: 'Coin').joins("left join coins on coins.id = commodities.detail_id")
  end

  def self.with_coin_theme(coin_theme)
    where(coins: {theme: coin_theme})
  end

  def self.with_coin_material(coin_material)
    where(coins: {material: coin_material})
  end

  def self.with_coin_weight(coin_weight)
    where(coins: {weight: coin_weight})
  end

  def self.with_coin_year(coin_year)
    where(coins: {year: coin_year})
  end

  def self.with_coin_face_value(coin_face_value)
    where(coins: {face_value: coin_face_value})
  end

  def self.with_coin_pack_spec(coin_pack_spec)
    where(coins: {pack_spec: coin_pack_spec})
  end

  def self.joins_bill
    Commodity.where(detail_type: 'Bill').joins("left join bills on bills.id = commodities.detail_id")
  end

  def self.with_bill_version(bill_version)
    where(bills: {version: bill_version})
  end

  def self.with_bill_engrave_year(bill_engrave_year)
    where(bills: {engrave_year: bill_engrave_year})
  end

  def self.with_bill_face_value(bill_face_value)
    where(bills: {face_value: bill_face_value})
  end

  def self.with_bill_pack_spec(bill_pack_spec)
    where(bills: {pack_spec: bill_pack_spec})
  end

  def self.with_bill_prefix(bill_prefix)
    where(bills: {prefix: bill_prefix})
  end

  def self.with_bill_serial_no(bill_serial_no)
    where(bills: {serial_no: bill_serial_no})
  end

  def self.with_bill_watermark(bill_watermark)
    where(bills: {watermark: bill_watermark})
  end

end
