class Sequence < ActiveRecord::Base
  # belongs_to :unit

  # def self.generate_asset_no(obj)
    # asset_no = nil
  	# if obj.asset_no.blank?
      # asset_no = Sequence.generate_barcode(Unit.find_by(id:(obj.use_unit_id.blank? ? obj.manage_unit_id : obj.use_unit_id)), obj.class, Sequence.generate_sequence(Unit.find_by(id:(obj.use_unit_id.blank? ? obj.manage_unit_id : obj.use_unit_id)), obj.class))
    # end
  # end

  Batchs = ["Catalog"]

  def self.initial
    Batchs.each do |x|
      x.to_s.constantize.class_eval do
        self.before_save do |obj|
          if obj.catalog_no.blank?
            obj.catalog_no = Sequence.generate_sequence( obj.class)
          end
          return true
        end
      end
    end
  end

  def self.generate_sequence(_class)
    get_count(_class).to_s.rjust(7, '0')
  end

  # def self.generate_barcode(unit, _class, count)
    # self.generate_initial(unit, _class).upcase + count
  # end

  def self.get_count(_class)
      sequence = find_by(entity: _class.to_s)
      sequence ||= Sequence.create(entity: _class.to_s, count: 1)
      success = false
      while !success
        begin
          success = sequence.update(count: sequence.count + 1)
        rescue => e
          sequence.reload
        end
      end
      sequence.count - 1
  end
end








