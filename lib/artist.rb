class Artist
  attr_reader :id, :album_id
  attr_accessor :name

  def initialize(attributes)
    @name = attributes.fetch(:name)
    @id = attributes.fetch(:id)
  end
  
  def self.all
    returned_artists = DB.exec("SELECT * FROM artists;")
    artists = []
    returned_artists.each() do |artist|
      name = artist.fetch("name")
      id = artist.fetch("id").to_i
      artists.push(Artist.new({:name => name, :id => id}))
    end
    artists
  end

  def save
    result = DB.exec("INSERT INTO artists (name) VALUES ('#{@name}') RETURNING id;")
    @id = result.first().fetch("id").to_i
  end

  def ==(artist_to_compare)
    self.name() == artist_to_compare.name()
  end

  def self.clear
    DB.exec("DELETE FROM artists *;")
  end

  def self.find(id)
    artist = DB.exec("SELECT * FROM artists WHERE id = #{id};").first
    name = artist.fetch("name")
    id = artist.fetch("id").to_i
    Artist.new({:name => name, :id => id})
  end

  def update(attributes) #include EXISTS in if statement
    if (attributes.has_key?(:name)) && (attributes.fetch(:name) != nil)
      @name = attributes.fetch(:name) # if name exists in the attributes hash, we will retrieve it.
      DB.exec("UPDATE artists SET name = '#{@name}' WHERE id = #{@id};") #changing the name of the artist at id location.
    elsif (attributes.has_key?(:album_name)) && (attributes.fetch(:album_name) != nil)
      album_name = attributes.fetch(:album_name) # else if retrieve album name if it exists
      album = DB.exec("SELECT * FROM albums WHERE lower(name)='#{album_name.downcase}';").first #matching a case insensitive query to database string
      album_artists = DB.exec("SELECT album_id FROM albums_artists WHERE NOT EXISTS (SELECT artist_id FROM albums_artists)").first # this lets us select an album where there is no artist. This is because the association has not yet been made.
      if album != nil && album_artists == nil
        DB.exec("INSERT INTO albums_artists (album_id, artist_id) VALUES (#{album['id'].to_i}, #{@id});")
      end
    end
  end
  
  def delete
    DB.exec("DELETE FROM albums_artists WHERE artist_id = #{@id};")
    DB.exec("DELETE FROM artists WHERE id = #{@id};")
  end

  def albums # This is searching the DB where album_id and artist_id live
    albums = []
    results = DB.exec("SELECT album_id FROM albums_artists WHERE artist_id = #{@id};") # searching BY artist_id in albums_artist FOR all albums by that artist.
    results.each() do |result| #iterating through results and doing the following 
      album_id = result.fetch("album_id").to_i()
      album = DB.exec("SELECT * FROM albums WHERE id = #{album_id};")
      name = album.first().fetch("name")
      albums.push(Album.new({:name => name, :id => album_id}))
    end
    albums  
  end

end

# def songs
  #   Song.find_by_artist(self.id)
  # end

  # albuma_artsts = DB>exec("SELECT artist_id")

#sql statement to select( to find artist id), 

# we dont want dublicate albums in our join table. album_artists is a variable that is a album id from our join table where there is Not a artist id in the join table 

