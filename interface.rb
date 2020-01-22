require 'yaml'
require 'open-uri'
require 'nokogiri'
# take the info of the top 5 movies on IMDB and store them into an YML file
url = 'https://www.imdb.com/chart/top'
# access the page with ranking
html = open(url)
# parse the page content
doc = Nokogiri::HTML(html)
# take the link of the top 5
movie_links = []
doc.search(".titleColumn a").first(5).each do |element|
  movie_links << "https://www.imdb.com#{element[:href]}"
end

movies = []
# for each link
movie_links.each do |link|
  # access the page
  access = open(link, "Accept-Language" => 'en')
  # parse the page content
  doc = Nokogiri::HTML(access)
  # search for the elements we need:
  summary_item = doc.search('.credit_summary_item a')

  ## Cast (the three names we need are at the end of the summary_item, except for the last item)
  cast = []
  summary_item[-4..-2].each do |element|
    cast << element.text
  end

  ## Director
  director = summary_item.first.text

  ## Storyline (we need to remove the whitespace)
  storyline = doc.search('.canwrap p span').text.strip

  ## Title (we need to remove the year and the whitespace)
  title = doc.search('h1').text.gsub(/\(\d{4}\)/, "").strip

  ## Year (we need to remove the parenthesis)
  year = doc.search('#titleYear').text.gsub(/[\(\)]/, "")

  # store them in a Hash
  movie = {
    cast: cast,
    director: director,
    storyline: storyline,
    title: title,
    year: year.to_i
  }

  # serialize the Hash to a YML format
  yaml_movie = movie.to_yaml

  # write the Hash in the YML file (append)
  File.open('movies.yml', 'ab') do |file|
    file.write(yaml_movie)
  end
end







