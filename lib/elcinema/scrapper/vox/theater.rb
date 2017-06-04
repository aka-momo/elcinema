module Elcinema
  module Scrapper
    module Vox
      class Theater < ::Elcinema::Scrapper::Theater
        extend Base

        ## Methods
        def self.find(id)
          page = open_html(path: "cinemas/#{id.split(':').first}")

          {}.tap do |theater|
            theater[:id]        = id.to_s
            theater[:name]      = page.css('h1').first.text.strip + case id.split(':').last.to_sym
                                  when :gold
                                    ' (Gold)'
                                  when :'4dx'
                                    ' (4DX)'
                                  when :max
                                    ' (Max)'
                                  when :kids
                                    ' (Kids)'
                                  end.to_s
            theater[:image_url] = "#{base_url}/assets/images/" + case id.split(':').last.to_sym
                                  when :standard
                                    'logo-288x92.png'
                                  when :gold
                                    'experience/panel-gd-300x150.jpg'
                                  when :'4dx'
                                    'experience/panel-fx-300x150.jpg'
                                  when :max
                                    'experience/panel-mx-300x150.jpg'
                                  when :kids
                                    'experience/panel-kd-300x150.jpg'
                                  end
            theater[:address]   = page.css('main section:nth-child(2) p')
                                      .children[2..-1]
                                      .map { |c| t = c.text.strip ; t unless t == '' }
                                      .compact
                                      .join('. ')

            movies_path = page.css('main section:nth-child(2) .action.primary:not(.outline)').first[:href][1..-1]
            page = open_html(path: movies_path + '&o=az')
            theater[:movies] = page.css('.movie-compare').map do |elm|
              next unless elm.css('.showtimes strong').map { |s| s.text.strip.downcase }.include?(id.split(':').last)

              {}.tap do |movie|
                movie[:id]    = elm[:'data-slug']
                movie[:title] = elm.css('h2').first.text.strip
              end
            end.compact
          end
        end

        def self.load(page: 1)
          { theaters: [],
            has_more: false }
        end
      end
    end
  end
end
