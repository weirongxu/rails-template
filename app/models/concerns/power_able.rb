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

      self.define_method(:"#{field}=") do |groups|
        groups -= self.public_send(field)
        super(groups)
      end

      self.define_method(:"#{field.to_s.singularize}_ids=") do |group_ids|
        group_ids -= self.public_send(:"#{field.to_s.singularize}_ids")
        super(group_ids)
      end
    end

    def self.belongs_array_to(
      name,
      class_name: name.to_s.singularize.classify,
      foreign_key: "#{name}_id",
      primary_key: :id,
      dependent: nil,
      nil_ignore: true
    )
      primary_key = primary_key.to_sym

      class_eval <<-CODE, __FILE__, __LINE__ + 1
        def #{name}
          ids = self.#{foreign_key} || []
          Object.const_get('#{class_name}').where(#{primary_key}: ids)
        end

        def #{name}=(relateds)
          self.#{foreign_key} = relateds.map(&:#{primary_key})
        end
      CODE

      if dependent == :destroy
        after_destroy_commit { public_send(name)&.each(&:destroy) }
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
          raise "Range first type(#{datetime.first.class.name}) must datetime or Infinite"
        end
        if is_datetime.call(datetime.last)
          if datetime.exclude_end?
            conds.push("#{column} < '#{datetime.last.to_s}'")
          else
            conds.push("#{column} <= '#{datetime.last.to_s}'")
          end
        elsif not datetime.last.try(:infinite?)
          raise "Range last type(#{datetime.first.class.name}) must datetime or Infinite"
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
        raise "datetime type(#{datetime.class.name}) must Datetime or Range"
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
