require 'json'

class Spec
  attr_accessor :name, :status, :backtrace, :point_names

  def initialize(name=nil, status=nil, backtrace=nil)
    @name = name
    @status = status
    @backtrace = backtrace
  end

end

class RspecParser
  attr_accessor :specs

  # Context is the root directory of the project, as given when run with .universal/conrols/test
  def parse
    json = `rspec -f j spec/ 2> /dev/null`
    parse_spsecs(json)
  end

  def parse_specs(json)
    @specs = []
    json = JSON.parse(json)
    json['examples'].each do |example|
      spec = Spec.new("#{example['full_description']} #{example['description']}", example['status'])
      spec.backtrace = "#{example['exception']['class']}\n#{example['exception']['message']}\nexample['exception']['backtrace']" unless example['exception'].nil?
      @specs << spec
    end
  end

  def parse_points(input_file_content)
    lines = input_file_content.split("\n")
    lines.each do |line|
      line.chomp!
      point_names = line.split(" ").drop(1)
      test_name = line.split(" ").first
      @specs[test_name].point_names = point_names
    end
  end
end

option = ARGV[0] || 'specs'

parser = RspecParser.new
if option == 'specs'
  parser.parse
else
  parser.parse_points("moi")
end
