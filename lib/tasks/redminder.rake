# redminder - redmine overdue-issues notification task
# Copyright (c) 2011  Frank Schwarz, frank.schwarz@buschmais.com
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

desc <<-END_DESC
Send reminders of overdue issues.

Options:
  * project  => id or identifier of project (optional, default: all projects)

Example:
  rake redminder:notify project=webshop RAILS_ENV=production
END_DESC

namespace :redminder do
  task :notify => :environment do
    options = {}
    options[:project] = ENV['project'] if ENV['project']
    
    RedminderMailer.overdue_notifications(options)
  end
end
