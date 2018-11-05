module PowerAble
  extend ActiveSupport::Concern

  included do
    extend Enumerize

    def self.transaction_prod(*args, &block)
      if Rails.env.test?
        block.call
      else
        self.transaction(*args, &block)
      end
    end

    def transaction_prod(*args, &block)
      self.class.transaction_prod(*args, &block)
    end

    def self.enumerize(column, options={})
      super(column, {
        predicates: { prefix: true },
        scope: (not options.fetch(:multiple, false)),
      }.merge(options))
    end

    def self.has_and_belongs_to_many_uniq(field, *args)
      self.has_and_belongs_to_many(field, *args) do
        def <<(group)
          super(group) if not include?(group)
        end
      end

      self.define_singleton_method(:"#{field}=") do |groups|
        groups -= self.send(field)
        super(groups)
      end

      self.define_singleton_method(:"#{field.singularize}_ids=") do |group_ids|
        group_ids -= self.send(group_ids)
        super(group_ids)
      end
    end

    def self.belongs_array_to(column, class_name: column.to_s.singularize.classify, nil_ignore: true, **args)
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

      self.define_method("#{column}=") do |relateds|
        self.send("#{column}_id=", relateds.map(&:id))
      end
    end

    def self.date_or_range_to_where(column, datetime)
      is_datetime = ->(obj) {
        [Date, Time, DateTime].any? {|type| obj.is_a?(type)}
      }
      if datetime.is_a?(Range)
        conds = []
        if is_datetime.call(datetime.first)
          conds.push("#{column} >= '#{datetime.first.to_s}'")
        elsif not datetime.first.try(:infinite?)
          raise Exception.new("Range first type(#{datetime.first.class.name}) must datetime or Infinite")
        end
        if is_datetime.call(datetime.last)
          if datetime.exclude_end?
            conds.push("#{column} < '#{datetime.last.to_s}'")
          else
            conds.push("#{column} <= '#{datetime.last.to_s}'")
          end
        elsif not datetime.last.try(:infinite?)
          raise Exception.new("Range last type(#{datetime.first.class.name}) must datetime or Infinite")
        end
        sql = conds.join(' AND ')
        if sql.empty?
          '1=1'
        else
          sql
        end
      elsif is_datetime.call(datetime)
        "#{column} = '#{datetime.to_s}'"
      else
        raise Exception.new("datetime type(#{datetime.class.name}) must Datetime or Range")
      end
    end

    def serializer(options={})
      ActiveModelSerializers::SerializableResource.new(self, options).as_json
    end

    def self.raise_self!(error=nil)
      raise(ActiveRecord::RecordNotSaved.new(error || "Failed to save the record", self.new))
    end

    def raise_self!(error=nil)
      raise(ActiveRecord::RecordNotSaved.new(error || errors.full_messages.first || "Failed to save the record", self))
    end
  end
end
