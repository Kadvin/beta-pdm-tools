# @author Kadvin, Date: 12-6-6
require "ostruct"
module Accept
  #
  # = The stat unit
  #
  class Stat < OpenStruct
    def initialize(threshold = 20)
      @threshold = threshold
      super(:total => 0, :success => 0, :fails => 0, :avg => 0.0, :max => 0.0, :min => 10000.0,
             :over_total => 0, :over_avg => 0.0, :over_max => 0.0, :over_min => 10000.0)
    end

    def succeed(cost)
      cost = cost.to_f
      self.success += 1
      count(cost)
      over(cost) if( cost > @threshold )
    end

    def failed(cost)
      cost = cost.to_f
      self.fails += 1
      count(cost)
      over(cost) if( cost > @threshold )
    end

    def count(cost)
      self.avg = (self.avg * self.total + cost)/(self.total + 1)
      self.max = cost if cost > self.max
      self.min = cost if cost < self.min
      self.total += 1
    end

    def over(cost)
      self.over_avg = (self.over_avg * self.over_total + cost) / (self.over_total + 1)
      self.over_max = cost if cost > self.over_max
      self.over_min = cost if cost < self.over_min
      self.over_total += 1
    end

    def over_min
      return 0.0 if self.over_total == 0
      self.over_min
    end
  end
end