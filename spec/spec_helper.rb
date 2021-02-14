require "singleton"
require "rspec"

class InMemoryFS
  include Singleton

  def initialize
    self.in_memory_fs = {}
  end

  def write(path, data)
    in_memory_fs[path] = data
  end

  def read(path)
    in_memory_fs[path]
  end

  def delete(path)
    in_memory_fs[path] = nil
  end

  def file?(path)
    in_memory_fs.key?(path)
  end

  private

  attr_accessor :in_memory_fs
end

RSpec.configure do |config|
  config.before(:each) do
    allow(File).to receive(:file?) { |path| InMemoryFS.instance.file?(path) }
    allow(File).to receive(:read) { |path| InMemoryFS.instance.read(path) }
    allow(File).to receive(:write) { |path, data| InMemoryFS.instance.write(path, data) }
    allow(File).to receive(:delete) { |path| InMemoryFS.instance.delete(path) }

    allow(FileUtils).to receive(:mkdir_p)
    allow(Dir).to receive(:mkdir)
  end
end
