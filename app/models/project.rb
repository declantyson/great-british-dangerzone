# == Schema Information
#
# Table name: projects
#
#  id                     :integer          not null, primary key
#  title                  :string(255)
#  user_id                :integer
#  synopsis               :string(255)
#  genres                 :string(255)
#  format                 :string(255)
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#  thumbnail_file_name    :string(255)
#  thumbnail_content_type :string(255)
#  thumbnail_file_size    :integer
#  thumbnail_updated_at   :datetime
#

class Project < ActiveRecord::Base
  attr_accessible :format, :genres, :synopsis, :title, :user_id, :thumbnail
  belongs_to :user
  has_many :characters
  has_many :scenes
  has_many :locations
  has_many :musics
  has_many :inspirations
  has_many :feedbacks

  validates :title, presence: true, length: {minimum: 4, maximum: 255}
  validates :genres, presence: true
  validates :format, presence: true
  before_save validate :validate_proj_thumbnail
  has_attached_file :thumbnail, styles: { medium: "300x300>", thumb: "100x100>" }

  def validate_proj_thumbnail
     if self.thumbnail.queued_for_write[:original]
      dimensions = Paperclip::Geometry.from_file(self.thumbnail.queued_for_write[:original])
      self.errors.add(:thumbnail, "should be at least 165px wide") if dimensions.width < 165
     end
  end
  
  def get_thumbnail()
    avatar_html = "<img src='#{self.thumbnail.url(:original)}'/>"
    avatar_html.html_safe
  end
  
  def get_thing(thing, signed_in)
    a = []
    if signed_in
    	edit = "<i class='icon-search icon-white view-object' title='View'></i>&nbsp;<i class='icon-pencil icon-white edit-object' title='Edit'></i>"
    else
      edit = "<i class='icon-search icon-white view-object' title='View'></i>"
    end
    self.send(thing.to_sym).each_index do |i|
	    img = "<img src='#{self.send(thing.to_sym)[i].image.url}' alt='#{self.send(thing.to_sym)[i].name}'/>"
      a << "<a data-frame='/#{thing}/#{self.send(thing.to_sym)[i].id}' data-project='?id=#{self.id}'><div class='box populated-box'>#{img}<div class='title'><p><span class='object-title'>#{self.send(thing.to_sym)[i].name}</span> #{edit}</p></div></div></a>"
    end
    a.join.html_safe
  end
end
