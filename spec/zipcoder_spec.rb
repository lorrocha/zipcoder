RSpec.describe Zipcoder do
  it 'has a version number' do
    expect(Zipcoder::VERSION).not_to be nil
  end

  let(:test_csv_path) { Pathname.new("#{__dir__}" + '/data/test_csv.csv')}
  before :each do
    stub_const('Zipcoder::CSV_PATH', test_csv_path)
  end

  context '.find_all' do
    context 'returns a CSV::Table object with all lines that include the value string' do
      it 'when that string is a zipcode' do
        results = Zipcoder.find_all('99626')

        expect(results.length).to eq 1
        expect(results.values_at 'city').to eq [['Lower Kalskag']]
      end

      it 'when that string is a city' do
        results = Zipcoder.find_all('Lower Kalskag')

        expect(results.length).to eq 1
        expect(results.values_at 'zipcode').to eq [['99626']]
      end

      it 'when that string is a state' do
        results = Zipcoder.find_all('Alaska')

        expect(results.length).to eq 13
      end

      it 'when that string is a longitude' do
        results = Zipcoder.find_all('-162.4594')

        expect(results.length).to eq 1
        expect(results.values_at 'city').to eq [['Nunapitchuk']]
      end

      it 'when that string is part of a zipcode' do
        results = Zipcoder.find_all('578')

        expect(results.length).to eq 1
        expect(results.values_at 'city').to eq [["Eek"]]
      end

      it 'when that string is part of a city' do
        results = Zipcoder.find_all('Ka')

        expect(results.length).to eq 3
        expect(results.values_at 'city').to eq [["Kalskag"], ["Kasigluk"], ["Lower Kalskag"]]
      end

      context 'passing in case_insensitive:true as an option' do
        it 'when that string is a state' do
          results = Zipcoder.find_all('alaska', case_insensitive: true)

          expect(results.length).to eq 13
        end
      end
    end

    it 'raises an error if no lines are found' do
      search_term = 'BLOOOGAAAf'
      expect{ Zipcoder.find_all(search_term) }.to \
        raise_error(Zipcoder::ResultsNotFound, "There is no data found for value: #{search_term}")
    end
  end

  context '.identify' do
    context 'passing in a single value' do
      it 'defaults to the column being "zipcode" and returns a CSV::Table of matching tables' do
        result = Zipcoder.identify('99626').first

        expect(result.to_h).to eq({
          "country_code"        => "US",
          "zipcode"             => "99626",
          "city"                => "Lower Kalskag",
          "state"               => "Alaska",
          "state_abbreviation"  => "AK",
          "latitide"            => "61.5138",
          "longitude"           => "-160.36"
        })
        expect(result["longitude"]).to eq "-160.36"
      end
    end

    context 'passing in a hash object' do
      context 'when the column is zipcode' do
        it 'returns a CSV::Table for that zipcode' do
          results = Zipcoder.identify(zipcode: '99626').first

          expect(results.to_h).to eq({
            "country_code"        => "US",
            "zipcode"             => "99626",
            "city"                => "Lower Kalskag",
            "state"               => "Alaska",
            "state_abbreviation"  => "AK",
            "latitide"            => "61.5138",
            "longitude"           => "-160.36"
          })
          expect(results["longitude"]).to eq "-160.36"
        end

        it 'is agnostic to whether the argument is a string or a symbol' do
          results = Zipcoder.identify('zipcode' => '99626').first

          expect(results.to_h).to eq({
            "country_code"        => "US",
            "zipcode"             => "99626",
            "city"                => "Lower Kalskag",
            "state"               => "Alaska",
            "state_abbreviation"  => "AK",
            "latitide"            => "61.5138",
            "longitude"           => "-160.36"
          })
          expect(results["longitude"]).to eq "-160.36"
        end
      end

      context 'when the column is something else' do
        it 'returns a CSV::Table for that state' do
          results = Zipcoder.identify(state: 'Alabama')

          expect(results.length).to eq 9
          expect(results.first['city']).to eq "Opp"
        end
      end

      context 'when the column is something not present in the HEADERS_MAPPING' do
        it 'raises an error' do
          expect{ Zipcoder.identify('cars' => 'Lincoln') }.to raise_error(
            Zipcoder::HeaderNotSupported, "The column `cars` is not supported. Please add it to the HEADERS_MAPPING if it is intended to be supported."
          )
        end
      end

      context 'when the hash has multiple values' do
        it 'returns a CSV::Table object of lines that satisfy all query conditions' do
          results = Zipcoder.identify({state: 'Alaska', city: 'Kalskag'})

          expect(results.length).to eq 2
          expect(results.to_a).to eq ([
            ["country_code", "zipcode", "city", "state", "state_abbreviation", "latitide", "longitude"],
            ["US", "99607", "Kalskag", "Alaska", "AK", "61.541", "-160.3261"],
            ["US", "99626", "Lower Kalskag", "Alaska", "AK", "61.5138", "-160.36"]
          ])
        end

        it 'raises an error if one of the column names is not valid' do
          expect{ Zipcoder.identify({state: 'Alaska', citystate: 'Kalskag'}) }.to raise_error(
            Zipcoder::HeaderNotSupported, "The column `citystate` is not supported. Please add it to the HEADERS_MAPPING if it is intended to be supported."
          )
        end
      end

      context 'case_insensitive: true' do
        it 'returns a CSV::Table of matches regardless of the case' do
          results1 = Zipcoder.identify({state: 'Alaska'})
          results2 = Zipcoder.identify({state: 'alaska'}, {case_insensitive: true})

          expect(results1).to eq results2
        end
      end
    end
  end
end
