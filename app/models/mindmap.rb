class Mindmap < ApplicationRecord
  has_many :nodes
  has_many :connections
end
