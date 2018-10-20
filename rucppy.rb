#!/usr/bin/env ruby

require 'set'
require 'tmpdir'

def get_sources(filename)
  content = File.read(filename, mode: 'r')
  headers = content.scan(/^#include\ \"(.*?)\"$/m).map { |header| header[0] }
  headers.map do |header|
    source = File.path("#{PROJECT_DIR}/#{header.gsub(/.h$/, '.cpp')}")
    raise "File #{source} does not exist" unless File.exist? source

    source
  end.to_set
end

# def run(files)
# puts "Compiling #{files}..."
# Dir.mkdir('bin') unless Dir.exist?('bin')
# `g++ #{files} -o bin/a.out`
# system('bin/a.out')
# File.delete('bin/a.out')
# end

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
PROJECT_DIR = File.dirname(MAIN_FILE)

queue = Queue.new
queue.push MAIN_FILE
lookup = Set[]

loop do
  begin
    source = queue.pop(non_block = true)

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
