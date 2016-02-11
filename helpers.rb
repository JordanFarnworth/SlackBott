module Helpers
  @users = {
    U046R5JLB: "Colin",
    U04689UFR: "Ben",
    U046V3L3Q: "Zach",
    U046G5M1D: "Jordan"
  }

  def users
    @users
  end

  def shift_param string
    a = string.split(" ")
    a.shift
    a.join(" ")
  end
end
