# scan path for files and renames them putting into one folder

require 'optparse'
require 'fileutils'

class AudioBookConverter

  def initialize(options = {})
    @source_path = options.fetch :source, '~/Documents/AudioBooks/convert'
    @destination_path = options.fetch :destination, '~/Documents/AudioBooks/convert/converted'
    @file_extention = options.fetch :extention, 'mp3'
  end

  def run
    files = Dir.glob(File.join(@source_path, "**/*.#{@file_extention}")).delete_if {|f| File.directory?(f)}

    path_len = @source_path.size

    make_alphabet(files, path_len)
  end

  private

  def prepare_destination
    Kernel.system "mkdir -p #{@destination_path}"
  end

  def rename_file old_file, new_file
    FileUtils.cp old_file, File.join(@destination_path, new_file)
  end

  def make_alphabet(files, path_len)
    alphabet = ('a'..'z').step
    prev_chapter = nil
    part = 1
    chapter = nil

    files.each do |file|
      match = file.match(/(\d+)\/\d\d_\d\d_(\d+)/)
      next unless match
      current_chapter = match[1]

      if prev_chapter == current_chapter
        part += 1
      else
        chapter = alphabet.next if prev_chapter != current_chapter
        prev_chapter = current_chapter
        part = 1
      end

      new_file_name = "#{chapter}#{part}.#{@file_extention}"

      puts "#{file.slice(path_len..-1)}\t=>\t#{new_file_name}"
      rename_file file, new_file_name
    end
  end

end

options = {}
OptionParser.new do |opts|
  opts.banner = "Usage: abc.rb [options]"

  opts.on("-s PATH", "--source PATH", "Source path") do |value|
    options[:source] = value
  end

  opts.on("-d PATH", "--destination PATH", "Destination path") do |value|
    options[:destination] = value
  end

  opts.on("-e EXTENTION", "--extention EXTENTION", "File extention") do |value|
    options[:extention] = value
  end

end.parse!(ARGV)

puts options.inspect

converter = AudioBookConverter.new(options)
converter.run
