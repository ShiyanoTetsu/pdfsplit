# frozen_string_literal: true

require "open3"
require "tmpdir"
require "fileutils"
require "hexapdf"

RSpec.describe "pdfsplit CLI" do
  it "prints help" do
    stdout, stderr, status = Open3.capture3("bundle exec pdfsplit --help")
    expect(status.exitstatus).to eq(0)
    expect(stderr).to eq("")
    expect(stdout).to include("Usage:")
  end

  it "fails without arguments" do
    stdout, stderr, status = Open3.capture3("bundle exec pdfsplit")
    expect(status.exitstatus).to eq(1)
    expect(stderr).to include("Usage: pdfsplit")
    expect(stderr).to include("Error: missing")
    expect(stdout).to eq("")
  end

  it "fails when input is given but --pages is missing" do
    _stdout, stderr, status = Open3.capture3("bundle exec pdfsplit sample.pdf")
    expect(status.exitstatus).to eq(1)
    expect(stderr).to include("Usage:")
    expect(stderr).to include("--pages")
  end

  it "fails when --pages is 0" do
    _stdout, stderr, status = Open3.capture3("bundle exec pdfsplit sample.pdf --pages 0")
    expect(status.exitstatus).to eq(1)
    expect(stderr).to include("Usage:")
    expect(stderr).to include("--pages must be > 0")
  end

  it "fails when --pages is negative" do
    _stdout, stderr, status = Open3.capture3("bundle exec pdfsplit sample.pdf --pages -1")
    expect(status.exitstatus).to eq(1)
    expect(stderr).to include("Usage:")
    expect(stderr).to include("--pages must be > 0")
  end

  it "fails when --pages is string" do
    _stdout, stderr, status = Open3.capture3("bundle exec pdfsplit sample.pdf --pages privet")
    expect(status.exitstatus).to eq(1)
    expect(stderr).to include("Usage:")
    expect(stderr).to include("invalid")
  end

  it "prints version with --version" do
    stdout, stderr, status = Open3.capture3("bundle exec pdfsplit --version")
    expect(status.exitstatus).to eq(0)
    expect(stderr).to eq("")
    expect(stdout).to include(Pdfsplit::VERSION)
  end

  it "accepts --out DIR" do
    Dir.mktmpdir do |dir|
      input = File.join(dir, "input.pdf")
      out_dir = File.join(dir, "out")
      FileUtils.mkdir_p(out_dir)

      doc = HexaPDF::Document.new
      3.times { doc.pages.add }
      doc.write(input)

      _stdout, stderr, status = Open3.capture3(%(bundle exec pdfsplit "#{input}" --pages 2 --out "#{out_dir}"))

      expect(status.exitstatus).to eq(0)
      expect(stderr).to eq("")
      parts = Dir[File.join(out_dir, "*.pdf")]
      expect(parts.size).to eq(2)
    end
  end

  it "works without --out (defaults output dir)" do
    Dir.mktmpdir do |dir|
      input = File.join(dir, "input.pdf")

      doc = HexaPDF::Document.new
      3.times { doc.pages.add }
      doc.write(input)

      cmd = %(cd "#{dir}" && bundle exec pdfsplit "#{input}" --pages 2)
      _stdout, stderr, status = Open3.capture3(cmd)

      expect(status.exitstatus).to eq(0)
      expect(stderr).to eq("")

      default_out_dir = File.join(dir, "input")
      expect(Dir.exist?(default_out_dir)).to be(true)

      parts = Dir[File.join(default_out_dir, "input_part*.pdf")]
      expect(parts.size).to eq(2)
    end
  end

  it "fails when input file does not exist" do
    _stdout, stderr, status = Open3.capture3("bundle exec pdfsplit no_such_file.pdf --pages 2")

    expect(status.exitstatus).to eq(1)
    expect(stderr).to include("No such file").or include("no such file")
  end

  it "fails when more than one input file is given" do
    _stdout, stderr, status = Open3.capture3("bundle exec pdfsplit a.pdf b.pdf --pages 2")

    expect(status.exitstatus).to eq(1)
    expect(stderr).to include("Usage:")
    expect(stderr).to include("only one input").or include("one input")
  end

  it "fails when input is not a valid PDF" do
    Dir.mktmpdir do |dir|
      input = File.join(dir, "not_pdf.txt")
      File.write(input, "hello, not a pdf")

      _stdout, stderr, status = Open3.capture3(%(bundle exec pdfsplit "#{input}" --pages 2))

      expect(status.exitstatus).to eq(1)
      expect(stderr).to include("Error: invalid PDF")
    end
  end

  it "fails when output directory is not writable" do
    Dir.mktmpdir do |dir|
      input = File.join(dir, "input.pdf")
      out_dir = File.join(dir, "out")

      doc = HexaPDF::Document.new
      2.times { doc.pages.add }
      doc.write(input)

      Dir.mkdir(out_dir)
      File.chmod(0o555, out_dir)

      _stdout, stderr, status = Open3.capture3(%(bundle exec pdfsplit "#{input}" --pages 1 --out "#{out_dir}"))

      expect(status.exitstatus).to eq(1)
      expect(stderr).to include("Permission denied").or include("permission denied")
    ensure
      File.chmod(0o755, out_dir) if File.exist?(out_dir)
    end
  end

  it "fails when --out points to an existing file" do
    Dir.mktmpdir do |dir|
      input = File.join(dir, "input.pdf")
      out_path = File.join(dir, "out")

      doc = HexaPDF::Document.new
      2.times { doc.pages.add }
      doc.write(input)

      File.write(out_path, "I am a file, not a directory")

      _stdout, stderr, status = Open3.capture3(%(bundle exec pdfsplit "#{input}" --pages 1 --out "#{out_path}"))

      expect(status.exitstatus).to eq(1)
      expect(stderr).to include("Error: --out must be a directory")
    end
  end
end
