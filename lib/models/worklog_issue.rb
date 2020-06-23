
require 'models/hashable_init'

module AdjustmentMode
    AUTO = 1
    FIXED = 2
end

class WorklogIssue 
    include HashableInit

    attr_accessor :id
    attr_accessor :description
    attr_accessor :adjustment_mode
    attr_accessor :duration # The duration passed as String, e.g. 2h30m
    attr_accessor :converted_duration # The duration converted to seconds e.g. 2 * 60 * 60 + 30 * 60 = 9000
end