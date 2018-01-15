RSpec.describe Zipcoder::ZipcodeDownloader do
  let(:tmp_dir) { "#{__dir__}/tmp" }
  let(:zipfile) { double("zipfile") }
  let(:zipfile_content) { [["a", "two", "dimensional", "array", "of", "multiple", "values", "for", "testing", "the", "method"]] }
  let(:csv_path) { Pathname.new("#{tmp_dir}/test.csv") }

  after :each do
    # Clear out the tmp folder
    FileUtils.rm_f Dir.glob("#{tmp_dir}/*")
  end

  context '.download' do
    before :each do
      allow(zipfile).to receive(:read_content_from_zipfile).and_return(zipfile_content)
      allow(Zipcoder::ZipfileHandler).to receive(:get_zip_from_path).and_return(zipfile)
      stub_const("Zipcoder::CSV_PATH", csv_path)
    end

    it 'writes a to the specified path with headers' do
      Zipcoder::ZipcodeDownloader.download

      expect(File.read(csv_path)).to eq \
        "a,two,dimensional,array,of,the,method\n"
    end

  end

  context "#write_to_csv" do
    before :each do
      allow(zipfile).to receive(:read_content_from_zipfile).and_return(zipfile_content)
    end

    context "headers: true" do
      it 'will write the csv to the csv path correctly with the headers from the headers_mapping' do
        downloader = Zipcoder::ZipcodeDownloader.new(zipfile)
        downloader.write_to_csv(csv_path, true)

        expect(File.read(csv_path)).to eq \
          "country_code,zipcode,city,state,state_abbreviation,latitide,longitude\na,two,dimensional,array,of,the,method\n"
      end
    end

    context "headers: false" do
      it 'will write the csv to the csv path correctly without headers' do
        downloader = Zipcoder::ZipcodeDownloader.new(zipfile)
        downloader.write_to_csv(csv_path)

        expect(File.read(csv_path)).to eq "a,two,dimensional,array,of,the,method\n"
      end
    end
  end
end
