module Elcinema
  module Scrapper
    class Theater < Base
      ## Methods
      def self.all(with_details: false)
        page = 1

        [].tap do |theaters|
          loop do
            data = load(page: page)

            data[:theaters].each do |theater|
              theater = find(theater[:id]) if with_details
              theaters << theater unless theater.nil?
            end

            break unless data[:has_more]

            page += 1
          end
        end
      end
    end
  end
end
