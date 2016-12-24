require 'yaml'
require 'json'

require 'pp'


module MoviesDB
  class Movies
    def initialize(config_file = nil)
      config_file = ENV['HOME'] + "/.moviesdb-rc.yaml" if config_file == nil
      raise FileNotFound.new(config_file) unless File.exist?(config_file)

      @options    = YAML.load_file(config_file)
      @movies_db  = {}
    end

    def createDB
      movie_list = []
      @options[:movies].each do |movie_dir|
        puts "Getting list of movies from: #{movie_dir}"
        movie_list += Dir["#{movie_dir}/*/*"]
      end
      total = movie_list.length

      # Get movies metadata
      puts "Getting metadata from #{total} movies"
      pinwheel = %w{ | / - \\ }
      warnings = []
      @movies_db[:movies] = []
      @movies_db[:people] = {}
      @movies_db[:genres] = {}
      movie_list.each_with_index do |movie_path, index|
        break if index > 10

        filename = File.basename(movie_path)
        # percentage = ((index+1) * 100)/total
        # puts "#{index}/#{total} (#{percentage}%) : #{filename}"
        percentage = (index.to_f / total * 100).to_i
        print "\rProgress: #{percentage}% (#{index}/#{total}) ", pinwheel.rotate!.first
        metadata = {}

        `/usr/local/bin/SublerCLI -source "#{movie_path}" -listmetadata`.split("\n").each do |md|
          pair = md.split(": ")
          if pair != nil && pair.length > 1
            metadata.merge!(Hash[ pair[0].downcase.to_sym, pair.drop(1).join(": ") ])
          else
            warnings << "WARNING: Check movie '#{filename}', there is a problem with a metadata field, maybe an extra newline."
          end
        end

        metadata[:id]     = index + 1
        metadata[:"media kind"] = metadata[:"media kind"] != nil && @media_kind.key?(metadata[:"media kind"]) ? @media_kind[metadata[:"media kind"]] : "UNKNOWN (#{metadata[:"media kind"]})"

        metadata[:genre]  = metadata[:genre] != nil ? metadata[:genre].downcase : ''
        metadata[:genres] = metadata[:comments] != nil ? metadata[:comments].downcase.split(',').map{ |g| g.strip }.uniq : []
        metadata.delete(:comments)

        if metadata[:cast] != nil && metadata[:artist] != nil
          sep = ","
        else
          sep = ""
        end
        metadata[:cast] = "#{metadata[:cast]}#{sep}#{metadata[:artist]}" if metadata[:cast] != metadata[:artist]
        metadata.delete(:artist)
        metadata[:cast] = metadata[:cast] != nil ? metadata[:cast].downcase.split(',').map{ |a| a.strip }.uniq : []

        @movies_db[:movies].push(metadata)

        metadata[:cast].each do |name|
          if ! @movies_db[:people].key?(name)
            @movies_db[:people][name] = {
              :name   => name.split.map(&:capitalize).join(' '),
              :movies => [ metadata[:id] ],
            }
          else
            @movies_db[:people][name][:movies].push(metadata[:id])
          end
        end
        (metadata[:genres] + [metadata[:genre]]).uniq.each do |genre|
          if ! @movies_db[:genres].key?(genre)
            @movies_db[:genres][genre] = {
              :name   => genre.split.map(&:capitalize).join(' '),
              :movies => [ metadata[:id] ],
            }
          else
            @movies_db[:genres][genre][:movies].push(metadata[:id])
          end
        end
      end

      puts "\nDone"
      puts warnings.join("\n") if warnings.length > 0
    end

    def save_to_file
      @options[:output_formats].each do |output_format|
        File.open("movies.#{output_format}", 'w') do |f|
          case output_format
          when 'yaml'
            f.write @movies_db.to_yaml
          when 'json'
            f.write @movies_db.to_json
          end
        end
        puts "Data saved in: movies.#{output_format}"
      end
    end
  end
end
