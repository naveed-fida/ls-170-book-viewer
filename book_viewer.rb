require "sinatra"
require "sinatra/reloader" if development?
require "tilt/erubis"

helpers do
  def to_paragraphs(data)
    data.split("\n\n").each_with_index.map do |para, index|
      "<p id=paragraph#{index}>#{para}</p>"
    end.join
  end

  def highlight(text, term)
    index_of_term = text.index(term) - 25
    index_of_term = 0 if index_of_term < 0
    short_text = "...#{text[index_of_term, 60]}..."
    short_text.gsub(term, %(<strong>#{term}</strong>))
  end
end

before do
  @toc = File.read('data/toc.txt').split("\n")
end

get "/" do
  @title = 'The Adventures of Sherlock Holmes'
  erb :home
end

get "/chapter/:number" do |number|
  chapter_name = @toc[number.to_i - 1]
  @title = "Chapter #{number}: #{chapter_name}"
  @chapter = File.read("data/chp#{number}.txt")

  erb :chapter
end

get '/search' do
  if params[:query]
    @results = @toc.each_with_index.each_with_object([]) do |(chapter, index), results|
      text = File.read("data/chp#{index+1}.txt")
      paragraphs = text.split("\n\n")
      paragraphs.each_with_index do |paragraph, pargraph_index|
        if paragraph.include?(params[:query])
          results << [chapter, index, paragraph, pargraph_index]
        end
      end
    end
  end

  erb :search
end

not_found do
  redirect '/'
end