module JournalUserTags
  
  def notified_users_with_easy_extensions
    tagged_user_names = self.notes.scan(/(?<=@)[A-Za-z0-9_\-\.]{1,}/).map(&:downcase)
    tagged_users      = User.where("LOWER(login) IN (#{tagged_user_names.map {|u| "'#{u}'"}.join(",")})")
    
    tagged_users + super
  end
  
end

Journal.send :prepend, JournalUserTags
