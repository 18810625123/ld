class Ld::Files < Array

  attr_accessor :results

  def initialize files
    @results = files
  end

  def find name
    @results.each do |f|
      if f.name == name
        return f
      end
    end
    nil
  end

end