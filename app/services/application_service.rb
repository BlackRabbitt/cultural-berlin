# frozen_string_literal: true

class ApplicationService
  def initialize
    @failures = []
  end

  def self.call(*args)
    new(*args).call
  end
end
