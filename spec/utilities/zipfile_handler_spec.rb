RSpec.describe Zipcoder::ZipfileHandler do
  context '.get_zip_from_uri' do
    it 'will get a zipfile handler from the uri appropriately' do
      zh = Zipcoder::ZipfileHandler.get_zip_from_path("#{__dir__}/../data/zip_with_a_first_and_second.zip")
      expect(zh.read_content_from_zipfile('zip_with_a_first.txt_and_second.txt/first.txt')).to eq [["first"]]
    end
  end

  context '#read_content_from_zipfile' do
    let(:zipped_file) { open("#{__dir__}/../data/zip_with_a_first_and_second.zip") }
    let(:zh) { Zipcoder::ZipfileHandler.new(zipped_file) }

    it 'can read and parse one of the files specified in a zipped directory' do
      expect(zh.read_content_from_zipfile('zip_with_a_first.txt_and_second.txt/first.txt')).to eq [["first"]]
    end

    it 'can read and parse the other file specified in a zipped directory' do
      expect(zh.read_content_from_zipfile('zip_with_a_first.txt_and_second.txt/second.txt')).to eq [["second"]]
    end

  end


  context '#format_string' do
    let(:formated_array) { [%w[hello darkness my old friend], %w[i've come to talk with you again]] }
    let(:unformated_string) { "hello\tdarkness\tmy\told\tfriend\ni've\tcome\tto\ttalk\twith\tyou\tagain" }

    it "breaks apart a tab seperated string appropriately" do
      zh = Zipcoder::ZipfileHandler.new('')
      expect(zh.send(:format_string, unformated_string)).to eq formated_array
    end

    it "appropriately handles strange quotations and empty slots" do
      good = [[ "\"something\"", ",", " ",], ["'hi'", " "]]
      bad = "\"something\"\t,\t \t\n'hi'\t \t"

      zh = Zipcoder::ZipfileHandler.new('')
      expect(zh.send(:format_string, bad)).to eq good
    end
  end

end
