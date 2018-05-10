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
  end

  def serializer(options={})
    ActiveModelSerializers::SerializableResource.new(self, options).as_json
  end

  def raise_self(error=nil)
    raise(ActiveRecord::RecordNotSaved.new(error || errors.full_messages.first || "Failed to save the record", self))
  end
end
