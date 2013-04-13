# redminder - redmine overdue-issues notification task
# Copyright (c) 2013  Frank Schwarz, frank.schwarz@buschmais.com
# Copyright (C) 2006-2013  Jean-Philippe Lang
#
# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License
# as published by the Free Software Foundation; either version 2
# of the License, or (at your option) any later version.
# 
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
# 
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.

class RedminderMailer < Mailer
  include Redmine::I18n

  def self.overdue_notifications(options={})
    project = options[:project] ? Project.find(options[:project]) : nil
    yesterday = Time.now - (24 * 60 * 60)

    scope = Issue.open.where(
      "#{Issue.table_name}.assigned_to_id IS NOT NULL" +
      " AND #{Project.table_name}.status = #{Project::STATUS_ACTIVE}" +
      " AND #{Issue.table_name}.due_date <= ?", yesterday
    )
    scope = scope.where(:project_id => project.id) if project

    issues_by_assignee = scope.includes(:assigned_to, :project).all.group_by(&:assigned_to)
    issues_by_assignee.keys.each do |assignee|
      if assignee.is_a?(Group)
        assignee.users.each do |user|
          issues_by_assignee[user] ||= []
          issues_by_assignee[user] += issues_by_assignee[assignee]
        end
      end
    end

    issues_by_assignee.each do |assignee, issues|
      overdue_notification(assignee, project, issues).deliver if assignee.is_a?(User) && assignee.active?
    end
  end

  def overdue_notification(user, project, issues)
    set_language_if_valid user.language

    prefix = project ? "[#{project.name}] " : '[Redmine] '
    subject = prefix + l(:redminder_mail_subject)

    issues.sort!{|a, b| a.id <=> b.id }
    @issues_by_project = issues.group_by { |issue| issue.project }

    mail :to => user.mail, :subject => subject
  end

end
