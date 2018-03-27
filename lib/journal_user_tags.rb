module JournalUserTags
  
  def notified_users_with_easy_extensions
    tagged_user_names = self.notes.scan(/(?<=@)[a-z0-9_\-\.]{1,}/)
    tagged_users      = User.where(login: tagged_user_names)
    
    tagged_users + super
  end
  
end

Journal.send :prepend, JournalUserTags
