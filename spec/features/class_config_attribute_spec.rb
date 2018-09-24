require 'rails_helper'

describe 'class extends', type: :feature do
  it 'config attribute' do
    class Base
      class_config_attribute :config, {base: 'base'}
      class_config_attribute :attr, nil
    end

    class A < Base
      config({a: 'a'})
      attr('a')

      def class_config
        self.class._config
      end
    end

    class B < Base
      config({b: 'b'})
      attr('b')

      def class_config
        self.class._config
      end
    end

    class D < Base
      config('a')
      attr('d')

      def class_config
        self.class._config
      end
    end

    expect(Base._config).to eq({base: 'base'})
    expect(A._config).to eq({base: 'base', a: 'a'})
    expect(B._config).to eq({base: 'base', b: 'b'})

    expect(Base.new.config).to eq({base: 'base'})
    expect(A.new.class_config).to eq({base: 'base', a: 'a'})
    expect(A.new.config).to eq({base: 'base', a: 'a'})
    expect(B.new.class_config).to eq({base: 'base', b: 'b'})
    expect(B.new.config).to eq({base: 'base', b: 'b'})

    expect(D._config).to eq('a')
    expect(D.new.config).to eq('a')
  end
end
