class Organization < ActiveRecord::Base
  has_many :people

  validates_presence_of :name
  alias_method :old_people, :people=

  def people=(person_hashes)
    people_to_add = person_hashes.map do |person_hash|
      Person.create!(person_hash).id
    end
    self.person_ids = people_to_add
  end
end
