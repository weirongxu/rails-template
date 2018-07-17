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

    def self.belongs_array_to(column, class_name: column.classify, nil_ignore: true)
      self.define_method(column) do
        ids = self.send("#{column}_id") || []
        id_models = Object.const_get(class_name).where(id: ids).index_by(&:id)
        ids.map do |id|
          id_models[id]
        end.yield_self do |models|
          if nil_ignore
            models.compact
          else
            models
          end
        end
      end
    end

    def self.date_or_range_to_where(column, datetime)
      def is_datetime(obj)
        [Date, Time, DateTime].any? {|type| obj.is_a?(type)}
      end
      if datetime.is_a?(Range)
        conds = []
        if is_datetime(datetime)
          conds.push("#{column} >= '#{datetime.first.to_s}'")
        elsif not datetime.first.try(:infinite?)
          raise Error("Range first type(#{datetime.first.class.name}) must datetime or Infinite")
        end
        if datetime.is_a?(Range)
          if datetime.exclude_end?
            conds.push("#{column} < '#{datetime.last.to_s}'")
          else
            conds.push("#{column} <= '#{datetime.last.to_s}'")
          end
        elsif not datetime.last.try(:infinite?)
          raise Error("Range last type(#{datetime.first.class.name}) must datetime or Infinite")
        end
        sql = conds.join(' AND ')
        if sql.empty?
          '1=1'
        else
          sql
        end
      elsif is_datetime(datetime)
        "#{column} = '#{datetime.to_s}'"
      else
        raise Error("datetime type(#{datetime.class.name}) must Datetime or Range")
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
