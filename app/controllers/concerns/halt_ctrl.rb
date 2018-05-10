module HaltCtrl
  extend ActiveSupport::Concern

  class Halt < StandardError; end

  included do
    rescue_from(Halt) do |err|
    end
  end

  # 调用后终止action进程
  def halt!
    raise Halt
  end
end
