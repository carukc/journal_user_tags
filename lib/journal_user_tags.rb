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
  
  class Hooks < Redmine::Hook::ViewListener
    render_on :view_issue_sidebar_top, :partial => 'issues/issue_answer_button'
    render_on :view_issues_edit_notes_bottom, :partial => 'issues/mention' 
    render_on :view_layouts_base_html_head, :partial => "issues/js_css"
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
