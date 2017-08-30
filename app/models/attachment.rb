class Attachment < ActiveRecord::Base
  belongs_to :client
  has_attached_file :file,
  									styles: { thumb: "400x300>" },
  									default_style: :thumb,
  									convert_options: {thumb: "-gravity North -extent 400x300"}
  validates_attachment_content_type :file, content_type: /\Aimage\/.*\Z/
end
