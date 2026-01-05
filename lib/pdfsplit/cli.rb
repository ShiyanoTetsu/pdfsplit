# frozen_string_literal: true

require "optparse"
require "fileutils"

module Pdfsplit
  class CLI
    def self.start(argv)
      pages = nil
      out_dir = nil

      parser = OptionParser.new do |opts|
        opts.banner = "Usage: pdfsplit INPUT.pdf --pages N [--out DIR]"

        opts.on("-h", "--help", "Show help") do
          puts opts
          return 0
        end

        opts.on("--pages N", Integer, "Pages per part") do |n|
          pages = n
        end

        opts.on("--version", "Show version") do
          puts Pdfsplit::VERSION
          return 0
        end

        opts.on("--out DIR", String, "Output directory") do |dir|
          out_dir = dir
        end
      end

      parser.parse!(argv)

      if argv.empty?
        warn "Error: missing INPUT.pdf"
        warn parser.to_s
        return 1
      end

      if argv.size != 1
        warn "Error: only one input .pdf is allowed"
        warn parser.to_s
        return 1
      end

      if pages.nil?
        warn "Error: missing --pages"
        warn parser.to_s
        return 1
      end

      if pages <= 0
        warn "Error: --pages must be > 0"
        warn parser.to_s
        return 1
      end


      input_path = argv.first

      if out_dir.nil?
        base_dir = File.dirname(input_path)
        base_name = File.basename(input_path, File.extname(input_path))
        out_dir   = File.join(base_dir, base_name)
      end

      if File.exist?(out_dir) && !File.directory?(out_dir)
        warn "Error: --out must be a directory"
        return 1
      end

      Pdfsplit::Splitter.split(input_path: input_path, pages_per_part: pages, out_dir: out_dir)
      0


    rescue OptionParser::ParseError => e
      warn e.message
      warn parser.to_s
      1
    rescue HexaPDF::Error
      warn "Error: invalid PDF"
      1
    rescue SystemCallError, Pdfsplit::Error => e
      warn e.message
      1
    end

  end
end
