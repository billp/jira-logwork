# InputOutput test helpers
class InputOutputHelpers
  def self.stub_input(inputs)
    string_io = StringIO.new
    inputs.each do |input|
      string_io.puts input
    end
    string_io.rewind
    $stdin = string_io
    yield
    $stdin = STDIN
  end

  def self.capture_output
    original_stdout = $stdout
    $stdout = StringIO.new
    yield
    $stdout.string
  ensure
    $stdout = original_stdout
  end
end
