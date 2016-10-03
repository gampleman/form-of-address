class Organization < ActiveRecord::Base
  has_many :people, dependent: :destroy

  validates_presence_of :name
  alias_method :old_people, :people=

  def people=(person_hashes)
    people_to_add = person_hashes.map do |person_hash|
      if person_hash[:id]
        Person.find(person_hash[:id]).update_attributes(person_hash.slice(:name, :email, :phone, :address))
      else
        Person.create!(person_hash).id
      end
    end
    self.person_ids = people_to_add
  end
end
