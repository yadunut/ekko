#!/usr/bin/env ruby

require 'set'
require 'tmpdir'

# get_sources takes in the filepath to a file and returns a Set of source files
# by reading the #include statements in the given file
def get_sources(filepath)
  content = File.read(filepath, mode: 'r')
  headers = content.scan(/^#include\ \"(.*?)\"$/m).map { |header| header[0] }
  file_dir = File.dirname(filepath)
  headers.map do |header|
    source = File.path("#{file_dir}/#{header.gsub(/.h$/, '.cpp')}")
    raise "File #{source} does not exist" unless File.exist? source

    source
  end.to_set
end

# run takes in a string of files seperated by spaces, compiles, runs, and
# deletes the tmpdir
def run(files)
  puts "Compiling #{files}..."
  Dir.mktmpdir('rucppy') do |dir|
    compile_command = "g++ #{files} -o #{dir}/a.out"
    puts compile_command
    `#{compile_command}`
    system("#{dir}/a.out")
  end
end

if ARGV.count.zero?
  STDERR.puts "Usage: #{$PROGRAM_NAME} <filename.cpp>"
  exit 1
end

MAIN_FILE = File.realpath(ARGV[0])

queue = Queue.new
queue.push MAIN_FILE
lookup = Set[]

loop do
  begin
    source = queue.pop(true)

    next if lookup.include? source

    lookup.add source
    new_sources = get_sources(source)
    new_sources.each { |filename| queue << filename }
  rescue ThreadError
    break
  end
end

files = ''
lookup.each { |file| files += "#{file} " }

run(files)
