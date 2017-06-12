class Ld::ParameterError
  attr_accessor :clazz, :hint

  def initialize clazz, hint
    @clazz = clazz
    @hint = hint
  end

  def self.create clazz, &block
    runtime_error = self.new clazz
    block.call runtime_error
    runtime_error
  end

  def add_run

  end

  def raise hash
    lines = []
    case hash[:error_type]
      when :example
        # lines =
      when :scope
        lines = [
            "scope参数说明:",
            "  1 不能为空",
            "  2 格式'单元格1:单元格2',如'A1:B2'代表读取以A1与B2为对角的矩形范围中的所有内容",
        ]
    end

    lines.each{|line| puts line}

  end

end
