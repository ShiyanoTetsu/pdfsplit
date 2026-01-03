# frozen_string_literal: true

RSpec.describe Pdfsplit do
  it "has a version number" do
    expect(Pdfsplit::VERSION).not_to be_nil
  end

  it "can load HexaPDF" do
    expect { require "hexapdf"}.not_to raise_error
  end
end
