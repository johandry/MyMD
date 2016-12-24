module MoviesDB
  module Tags
    extend FFI::Library

    SET_ARGS = [:MP4Tags, :string]

    ffi_lib ['libmp4v2']

    typedef :pointer, :MP4FileHandle
    typedef :pointer, :MP4Tags


  end
end
