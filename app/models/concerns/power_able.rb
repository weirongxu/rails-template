module PowerAble
  extend ActiveSupport::Concern

  included do
    extend Enumerize

    def self.enumerize(column, options={})
      super(column, {
        predicates: { prefix: true },
        scope: true
      }.merge(options))
    end

    def self.has_and_belongs_to_many_uniq(*args)
      self.has_and_belongs_to_many(*args) do
        def <<(group)
          group -= self if group.respond_to?(:to_a)
          super group unless include?(group)
        end
      end
    end

    def self.date_or_range2where(column, datetime)
      if datetime.is_a? Range
        conds = []
        if not datetime.first.try(:infinite?)
          conds.push("#{column} >= '#{datetime.first.to_s(:db)}'")
        elsif not datetime.last.try(:infinite?)
          if exclude_end?
            conds.push("#{column} < '#{datetime.last.to_s(:db)}'")
          else
            conds.push("#{column} <= '#{datetime.last.to_s(:db)}'")
          end
        end
        sql = conds.join(' AND ')
        if sql.empty?
          '1=1'
        else
          sql
        end
      else
        "#{column} = '#{datetime.to_s(:db)}'"
      end
    end
  end

  def serializer(options={})
    ActiveModelSerializers::SerializableResource.new(self, options).as_json
  end

  def raise_self(error=nil)
    raise(ActiveRecord::RecordNotSaved.new(error || errors.full_messages.first || "Failed to save the record", self))
  end
end
