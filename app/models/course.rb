class Course < ActiveRecord::Base
  include ActionView::Helpers::DateHelper # for time_ago_in_words
  # include ActionController::Base.helpers.link_to
  include Rails.application.routes.url_helpers

  # include Rails.application.routes.url_helpers
  has_many :reviews, dependent: :destroy
  has_one :professor
  has_one :department           # we can accept this for now
  default_scope -> { order(crn: :asc) } ## cached_votes_score

  make_flaggable
 

  def prof
    Professor.find(self.professor_id)
  end

  def prof_path
    Rails.application.routes.url_helpers.professor_path(prof)
  end

  def prof_name
    ActionController::Base.helpers.link_to(prof.name, prof_path)
  end

  def prof_name_raw
    prof.name
  end

  def dept
    Department.find(self.department_id)
  end

  def dept_path
    Rails.application.routes.url_helpers.department_path(dept)
  end

  def dept_name
    ActionController::Base.helpers.link_to(dept.name, dept_path)
  end

  def last
    if self.reviews.any?
      "Last reviewed " + time_ago_in_words(self.reviews.order('updated_at DESC')[0].updated_at) + " ago."
    else
      "No reviews yet — you could be the first!"
    end
  end

  def avg
    if self.reviews.any?
      count = self.reviews.count
      clarity, intensity, worthit = 0.0, 0.0, 0.0

      self.reviews.each { |r|
        clarity   +=  r.clarity.to_f
        intensity +=  r.intensity.to_f
        worthit   +=  r.worthit.to_f
      }

      clarity   /= count
      intensity /= count
      worthit   /= count

      { clarity: clarity.round(1), 
        workload: intensity.round(1), 
        worthit: worthit.round(1) 
      }
    else
      { clarity: "n/a", 
        workload: "n/a", 
        worthit: "n/a" 
      }
    end
  end
  
end
