# frozen_string_literal: true

# HashableInit module
module HashableInit
  def initialize(args)
    args.each do |key, value|
      send("#{key}=", value)
    end
  end
end
