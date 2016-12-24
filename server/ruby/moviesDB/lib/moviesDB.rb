require "moviesDB/version"
require "moviesDB/movies"

module MoviesDB

  class MovieDBError < StandardError
  end

  class FileNotFound < ::MoviesDB::MovieDBError
    attr_reader :filename

    def initialize(filename)
      @filename = filename
    end
    def to_s
      "File not found: #{filename}"
    end
  end

  def self.create(config_file = nil)
    movies = Movies.new(config_file)
    movies.createDB
    movies.save_to_file
  rescue MovieDBError => error
    STDERR.puts "[ERROR]\t#{$!}"
  end
end
