# frozen_string_literal: true

require "hexapdf"
require "fileutils"

module Pdfsplit
  class Splitter
    def self.split(input_path:, pages_per_part:, out_dir:)
      raise ArgumentError, "pages_per_part must be > 0" if pages_per_part.to_i <= 0

      FileUtils.mkdir_p(out_dir)

      doc = HexaPDF::Document.open(input_path)
      pages = doc.pages.to_a

      base = File.basename(input_path, File.extname(input_path))

      pages.each_slice(pages_per_part).with_index(1) do |slice, idx|
        out_doc = HexaPDF::Document.new
        slice.each do |page|
          out_doc.pages << out_doc.import(page)
        end

        out_path = File.join(out_dir, format("%s_part%03d.pdf", base, idx))
        out_doc.write(out_path)
      end

      true
    end
  end
end
