class Connection < ApplicationRecord
  belongs_to :mindmap, optional: true
end
