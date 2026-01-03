# frozen_string_literal: true

require "tmpdir"
require "fileutils"
require "hexapdf"
require "pdfsplit"

RSpec.describe Pdfsplit::Splitter do
  it "splits a PDF into parts of N pages; page counts is correct" do
    Dir.mktmpdir do |dir|
      input = File.join(dir, "input.pdf")
      out_dir = File.join(dir, "out")
      FileUtils.mkdir_p(out_dir)

      doc = HexaPDF::Document.new
      3.times { doc.pages.add }
      doc.write(input)

      Pdfsplit::Splitter.split(input_path: input, pages_per_part: 2, out_dir: out_dir)

      expected1 = File.join(out_dir, "input_part001.pdf")
      expected2 = File.join(out_dir, "input_part002.pdf")
      expect(File.exist?(expected1)).to be(true)
      expect(File.exist?(expected2)).to be(true)


      parts = [expected1, expected2]
      expect(parts.size).to eq(2)

      part1 = HexaPDF::Document.open(parts[0])
      part2 = HexaPDF::Document.open(parts[1])

      expect(part1.pages.count).to eq(2)
      expect(part2.pages.count).to eq(1)
    end
  end

  it "creates a single part when pages_per_part is greater than total pages" do
    Dir.mktmpdir do |dir|
      input = File.join(dir, "input.pdf")
      out_dir = File.join(dir, "out")
      FileUtils.mkdir_p(out_dir)

      doc = HexaPDF::Document.new
      3.times { doc.pages.add }
      doc.write(input)

      Pdfsplit::Splitter.split(input_path: input, pages_per_part: 10, out_dir: out_dir)

      parts = Dir[File.join(out_dir, "*.pdf")].sort
      expect(parts.size).to eq(1)

      part = HexaPDF::Document.open(parts[0])
      expect(part.pages.count).to eq(3)
    end
  end

  it "output file names are correct" do
    Dir.mktmpdir do |dir|
      input = File.join(dir, "input.pdf")
      out_dir = File.join(dir, "out")
      FileUtils.mkdir_p(out_dir)

      doc = HexaPDF::Document.new
      3.times { doc.pages.add }
      doc.write(input)

      Pdfsplit::Splitter.split(input_path: input, pages_per_part: 2, out_dir: out_dir)

      expected1 = File.join(out_dir, "input_part001.pdf")
      expected2 = File.join(out_dir, "input_part002.pdf")

      expect(File.exist?(expected1)).to be(true)
      expect(File.exist?(expected2)).to be(true)
    end
  end





end
