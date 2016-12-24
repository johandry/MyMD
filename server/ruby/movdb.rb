#!/usr/bin/env ruby

require 'optparse'
require 'yaml'
require 'json'

require 'pp'

Version = '1.0.0'

class Params
  def self.validate(options)
    error = false
    # Validate Volumes
    movies_path = options[:movies] + options[:backups] + options[:sources]
    movies_path.each do |d|
      base, share = d.split('/')[1..2]

      if ! Dir.exist?("/#{base}/#{share}")
        if (options[:password] == nil) or (options[:password] == '')
          puts "ERROR: Password is required"
          error = true
          break
        end
        Dir.mkdir("/#{base}/#{share}")
        system("mount -t smbfs //#{options[:username]}:#{options[:password]}@#{options[:host]}/#{share.sub(' ','%20')} '/#{base}/#{share}'")
      end

      if ! Dir.exist?(d)
        puts "ERROR: Directory #{d} does not exists."
        error = true
      # else
      #   p "OK: Directory #{d}"
      end
    end

    # Validate external tools
    # if ! File.exist?(options[:subler])
    #   puts "ERROR: SublerCLI is not found (#{options[:subler]}). Install it with 'brew cask install sublercli'"
    #   error = true
    # end
    if ! File.exist?(options[:atomicparsley])
      puts "ERROR: AtomicParsley is not found (#{options[:subler]}). Install it with 'brew install atomicparsley'"
      error = true
    end

    exit 1 if error
  end

  def self.parse(args)
    options = YAML.load_file('config.yaml')

    options[:username] = ENV["USER"]

    optionParser = OptionParser.new do |opts|
      opts.banner = "Usage: #$0 [options]"
      opts.separator ""
      opts.separator "Options:"

      opts.on('-h', '--help', 'Print this help') {
        puts opts
        exit
      }
      opts.on('--version', "Show version") {
        puts Version
        exit
      }
      opts.on('-u', '--user USER', 'Username to login to shared volumen.', "  Default: #{options[:username]}") { |v| options[:username] = v }
      opts.on('-p', '--password PASSWORD', 'Password to login to shared volumen', "  Default: #{options[:password]}") { |v| options[:password] = v }
      opts.on('-s', '--share HOST', 'Host where the shared volumen is', "  Default: #{options[:host]}") { |v| options[:host] = v }
      opts.on('-v', '--[no-]verbose', 'Provide more information, or not', "  Default: #{options[:verbose]}") { |v| options[:verbose] = v }
    end

    optionParser.parse!(args)

    self.validate(options)

    return options
  end
end


class Movies
  attr_accessor :movie_db

  def initialize(options)
    @movies_db  = {}
    @options    = options

    @media_kind = {
      '0' => "Movie",
      '1' => "Music",
      '2' => "Audiobook",
      '6' => "Music Video",
      '9' => "Movie",
      '10' => "TV Show",
      '11' => "Booklet",
      '14' => "Ringtone",
    }

    @atoms = {
      '©alb'  => 'Album',
      '©art'  => 'Artist',
      'aART'  => 'Album Artist',
      '©cmt'  => 'Comment',
      '©day'  => 'Year',
      '©nam'  => 'Title',
      '©gen'  => 'Genre',
      'gnre'  => 'Genre',
      'trkn'  => 'Track number',
      'disk'  => 'Disk number',
      '©wrt'  => 'Composer',
      '©too'  => 'Encoder',
      'tmpo'  => 'BPM',
      'cprt'  => 'Copyright',
      'cpil'  => 'Compilation',
      'covr'  => 'Artwork',
      'rtng'  => 'Rating/Advisory',
      '©grp'  => 'Grouping',
      'stik'  => 'Media Kind',
      'pcst'  => 'Podcast',
      'catg'  => 'Category',
      'keyw'  => 'Keyword',
      'purl'  => 'Podcast URL',
      'egid'  => 'Episode Global Unique ID',
      'desc'  => 'Description',
      'ldes'  => 'Long Description',
      '©lyr'  => 'Lyrics',
      'tvnn'  => 'TV Network Name',
      'tvsh'  => 'TV Show Name',
      'tven'  => 'TV Episode Number',
      'tvsn'  => 'TV Season',
      'tves'  => 'TV Episode',
      'purd'  => 'Purchase Date',
      'pgap'  => 'Gapless Playback',
    }
  end

  def create_db
    # Get movies list
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

      # Break after 10 movies for testing only.
      # In production are 1637 movies to process and takes a long time.
      break if index > 10

      filename = File.basename(movie_path)
      # percentage = ((index+1) * 100)/total
      # puts "#{index}/#{total} (#{percentage}%) : #{filename}"
      percentage = (index.to_f / total * 100).to_i
      print "\rProgress: #{percentage}% (#{index}/#{total}) ", pinwheel.rotate!.first
      metadata = {}
      # `/usr/local/bin/SublerCLI -source "#{movie_path}" -listmetadata`.split("\n").each do |md|
      #   pair = md.split(": ")
      #   if pair != nil && pair.length > 1
      #     metadata.merge!(Hash[ pair[0].downcase.to_sym, pair.drop(1).join(": ") ])
      #   else
      #     warnings << "WARNING: Check movie '#{filename}', there is a problem with a metadata field, maybe an extra newline."
      #   end
      # end
      `#{@options[:atomicparsley]} "#{movie_path}" -t`.split('Atom ').each do |md|
        pair = md.split('contains: ')
        if pair != nil && pair.length > 1
          key = pair[0].downcase.tr('"','').strip
          if @atoms.key?(key)
            metadata.merge!(Hash[ @atoms[key].to_sym, pair.drop(1).join("contains: ") ])
          else
            warnings << "WARNING: Check movie '#{filename}', there is an unknown key '#{key}'."
          end
        else
          warnings << "WARNING: Check movie '#{filename}', there is a problem with a metadata field, maybe an extra newline."
        end
      end

      # pp metadata

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

options = Params.parse(ARGV)
movies = Movies.new(options)
movies.create_db
movies.save_to_file
