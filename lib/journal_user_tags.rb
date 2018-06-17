module JournalUserTags
  
  module JournalExtension
  
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
  
  module IssueExtension
    
    def answer_to_users_for(user)
      if @_answer_to_users_for.present?
        return @_answer_to_users_for
      else
        answer_to_users_for = []
        
        if self.assigned_to == user
          # allow to answer to author when ticket is assigned to user and no journal exists
          # TODO: Should answering to author always be an option? 
          if self.journals.empty? && self.author != user
            answer_to_users_for << self.author
          else
            # getting last twso users from journal
            last_users = self.journals.where.not(user_id: user.id).order(:created_on).group(:user_id).map(&:user).compact.last(2)
        
            answer_to_users_for = last_users
          end
        end  
          
        @_answer_to_users_for = answer_to_users_for
      end
    end
    
  end
  
  class Hooks < Redmine::Hook::ViewListener
    render_on :view_issue_sidebar_top, :partial => 'issues/issue_answer_button'
    render_on :view_issues_edit_notes_bottom, :partial => 'issues/mention' 
    render_on :view_layouts_base_html_head, :partial => "issues/css"
    render_on :view_layouts_base_body_bottom, :partial => "issues/js"
  end
  
end

IssuesController.class_eval do
  
  skip_before_action :authorize, only: [:answer]
  
  def answer
    @issue = Issue.find(params[:id])
    @project = @issue.project
    edit

    @issue.assigned_to_id = params[:to_user_id]

    render "edit"
  end
end

Journal.send :prepend, JournalUserTags::JournalExtension
RedmineExtensions::PatchManager.register_model_patch 'Issue', 'JournalUserTags::IssueExtension'