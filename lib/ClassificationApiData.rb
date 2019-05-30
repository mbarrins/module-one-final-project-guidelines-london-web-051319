class ClassificationApiData < ApiData
  attr_reader :segments, :genres, :sub_genres

  def initialize(url:, search_string: nil, api_key: nil, page_no: 0, page_size: 10)
    super
    @segments = Set.new
    @genres = Set.new
    @sub_genres = Set.new
  end

  def populate_tables
    if !data
      get_data
    end
      collect_into_subsets
      update_tables
  end

  private

  def collect_into_subsets
    data["_embedded"]["classifications"][11..-1].each do |c|
      segments.add({tm_segment_id: c["segment"]["id"], segment_name: c["segment"]["name"]})
      
      c["segment"]["_embedded"]["genres"].each do |g|
        genres.add({tm_genre_id: g["id"], genre_name: g["name"], segment_id: c["segment"]["id"]})
        
        g["_embedded"]["subgenres"].each do |s|
          sub_genres.add({tm_sub_genre_id: s["id"], sub_genre_name: s["name"], genre_id: g["id"]})
        end
      end
    end
  end

  def update_tables
    segments.each do |segment|
      if !Segment.find_by(tm_segment_id: segment[:tm_segment_id])
        Segment.create(segment)
      end
    end

    genres.each do |genre|
      genre[:segment_id] = (!!Segment.find_by(tm_segment_id: genre[:segment_id]) ? Segment.find_by(tm_segment_id: genre[:segment_id]).id : genre[:segment_id])
    end

    genres.each do |genre|
      if !Genre.find_by(tm_genre_id: genre[:tm_genre_id])
        Genre.create(genre)
      end
    end

    sub_genres.each do |sub_genre|
      sub_genre[:genre_id] = (!!Genre.find_by(tm_genre_id: sub_genre[:genre_id]) ? Genre.find_by(tm_genre_id: sub_genre[:genre_id]).id : sub_genre[:genre_id])
    end

    sub_genres.each do |sub_genre|
      if !SubGenre.find_by(tm_sub_genre_id: sub_genre[:sub_genre_id])
        SubGenre.create(sub_genre)
      end
    end
    
  end
end