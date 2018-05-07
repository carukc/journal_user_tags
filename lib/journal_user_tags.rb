module JournalUserTags
  
  def notified_users_with_easy_extensions
    tagged_user_names = self.notes.to_s.scan(/(?<=@)[A-Za-z0-9_\-\.]{1,}/).map(&:downcase)
    if tagged_user_names.any?
      tagged_users      = User.where("LOWER(login) IN (#{tagged_user_names.map {|u| "'#{u}'"}.join(",")})")
      tagged_users + super
    else
      super
    end  
  end
  
end

Journal.send :prepend, JournalUserTags
