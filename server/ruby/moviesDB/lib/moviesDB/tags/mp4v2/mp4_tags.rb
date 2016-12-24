module MoviesDB
  module Tags
    module Mp4v2
      class MP4Tags < FFI::Struct
        layout :__handle, :pointer,
               :name, :string,
               :artist, :string,
               :album_artist, :string,
               :album, :string,
               :grouping, :string,
               :composer, :string,
               :comments, :string,
               :genre, :string,
               :genreType, :pointer,
               :releaseDate, :string,
               :track, :pointer,
               :disk, :pointer,
               :tempo, :pointer,
               :compilation, :pointer,
               :tvShow, :string,
               :tvNetwork, :string,
               :tvEpisodeID, :string,
               :tvSeason, :pointer,
               :tvEpisode, :pointer,
               :description, :string,
               :longDescription, :string,
               :lyrics, :string,
               :sortName, :string,
               :sortArtist, :string,
               :sortAlbumArtist, :string,
               :sortAlbum, :string,
               :sortComposer, :string,
               :sortTVShow, :string,
               :artwork, :pointer,
               :artworkCount, :uint32

              #  :copyright, :string,
              #  :encodingTool, :string,
              #  :encodedBy, :string,
              #  :purchaseDate, :string

              #  :podcast,
              #  :keywords,
              #  :category,
               #
              #  :hdVideo,
              #  :mediaType,
              #  :contentRating,
              #  :gapless,
               #
              #  :iTunesAccount,
              #  :iTunesAccountType,
              #  :iTunesCountry,
              #  :contentID,
              #  :artistID,
              #  :playlistID,
              #  :genreID,
              #  :composerID,
              #  :xid,


              #  void* __handle; /* internal use only */
               #
              #  const char*        name;
              #  const char*        artist;
              #  const char*        albumArtist;
              #  const char*        album;
              #  const char*        grouping;
              #  const char*        composer;
              #  const char*        comments;
              #  const char*        genre;
              #  const uint16_t*    genreType;
              #  const char*        releaseDate;
              #  const MP4TagTrack* track;
              #  const MP4TagDisk*  disk;
              #  const uint16_t*    tempo;
              #  const uint8_t*     compilation;
               #
              #  const char*     tvShow;
              #  const char*     tvNetwork;
              #  const char*     tvEpisodeID;
              #  const uint32_t* tvSeason;
              #  const uint32_t* tvEpisode;
               #
              #  const char* description;
              #  const char* longDescription;
              #  const char* lyrics;
               #
              #  const char* sortName;
              #  const char* sortArtist;
              #  const char* sortAlbumArtist;
              #  const char* sortAlbum;
              #  const char* sortComposer;
              #  const char* sortTVShow;
               #
              #  const MP4TagArtwork* artwork;
              #  uint32_t             artworkCount;
               #
              #  const char* copyright;
              #  const char* encodingTool;
              #  const char* encodedBy;
              #  const char* purchaseDate;
               #
              #  const uint8_t* podcast;
              #  const char*    keywords;  /* TODO: Needs testing */
              #  const char*    category;
               #
              #  const uint8_t* hdVideo;
              #  const uint8_t* mediaType;
              #  const uint8_t* contentRating;
              #  const uint8_t* gapless;
               #
              #  const char*     iTunesAccount;
              #  const uint8_t*  iTunesAccountType;
              #  const uint32_t* iTunesCountry;
              #  const uint32_t* contentID;
              #  const uint32_t* artistID;
              #  const uint64_t* playlistID;
              #  const uint32_t* genreID;
              #  const uint32_t* composerID;
              #  const char*     xid;

        def self.keys
          [
            :name, :artist, :album_artist, :album,
            :grouping, :composer, :comments, :genre,
            :genreType, :releaseDate, :track, :disk,
            :tempo, :compilation, :tvShow, :tvNetwork,
            :tvEpisodeID, :tvSeason, :tvEpisode,
            :description, :longDescription, :lyrics,
            :sortName, :sortArtist, :sortAlbumArtist,
            :sortAlbum, :sortComposer, :sortTVShow,
            :artwork, :artworkCount,
            # :copyright,
            # :encodingTool, :encodedBy, :purchaseDate
          ]
        end
      end
    end
  end  
end
