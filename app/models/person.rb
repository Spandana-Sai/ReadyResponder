class Person < ActiveRecord::Base
  
  attr_accessible :firstname, :lastname, :status, :icsid, :city, :state, :zipcode, :start_date, :title, :gender, :date_of_birth,:division1, :division2, :certs_attributes
  has_many :certs
  has_many :courses, :through => :certs
  has_many :skills, :through => :courses
  has_and_belongs_to_many :titles

  accepts_nested_attributes_for :certs
  
  validates_presence_of :firstname, :lastname, :status
  validates_uniqueness_of :icsid, :allow_nil => true, :allow_blank => true   # this needs to be scoped to active members, or more sophisticated rules
  validates_length_of :state, :is =>2, :allow_nil => true, :allow_blank => true
  validates_numericality_of  :position, :height, :weight, :allow_nil => true
  validates_presence_of :division2, :unless => "division1.blank?"
  validates_presence_of :division1, :unless => "division2.blank?"
  
  
  scope :leave, :conditions => {:status => "Leave of Absence"}
  scope :inactive, :conditions => {:status => "Inactive"}
  scope :active, :order => 'position, start_date ASC', :conditions => {:status => "Active"}
  scope :divisionC, :order => 'position, start_date ASC', :conditions => {:division1 => "Command", :status => "Active"}
  scope :division1, :order => 'position, start_date ASC', :conditions => {:division1 => "Division 1",
                                        :status => "Active"}
  scope :division2, :order => 'position, start_date ASC', :conditions => {:division1 => "Division 2",
                                        :status => "Active"}
  scope :squadC, :order => 'position, start_date ASC', :conditions => {:division2 => "Command",
                                        :status => "Active"}
  scope :unassigned, :order => 'position, start_date ASC', :conditions => {:division1 => "Unassigned",
                                        :status => "Active"}
  scope :squad1, :order => 'position, start_date ASC', :conditions => {:division2 => "Squad 1",:status => "Active"}
  scope :squad2, :order => 'position, start_date ASC', :conditions => {:division2 => "Squad 2",:status => "Active"}

  TITLES = ['Director','Chief','Deputy','Captain', 'Lieutenant','Sargeant', 'Corporal', 'Senior Officer', 'Officer', 'CERT', 'Dispatcher', 'Recruit','Student Officer']
  
  def fullname
    (self.firstname + " " + (self.middleinitial || "") + " " + self.lastname).squeeze(" ")
  end
  
  def shortrank
    ranks = { "Chief" => "Chief", "Deputy Chief" => "Deputy", "Captain" => "Capt",
            "Lieutenant" => "Lt", "Sargeant" => "Sgt", "Corporal" => "Cpl",
            "Senior Officer" => "SrO", "Officer" => "Ofc", "Dispatcher" => "Dsp",
            "Recruit" => "Rct" }
    ranks[self.title] || ''
  end
  
  def name
    (self.firstname + " " + self.lastname)
  end
  
  def csz
    self.city + " " + self.state + " " + self.zipcode
  end
  
  def self.search(search)
    if search
      find :all, :conditions => ['firstname LIKE ? OR lastname LIKE ? OR city LIKE ? OR memberID like ?',
        "%#{search}%","%#{search}%","%#{search}%","%#{search}%"],
        :order => 'division1, division2,position, start_date ASC'
    else
      find :all, :order => 'division1, division2,position, start_date ASC'
    end
  end
  def age
    if self.date_of_birth.present?
      now = Date.today
      age = now.year - self.date_of_birth.year
      age -= 1 if now.yday < self.date_of_birth.yday
    end
      age
  end
  
  def service_duration
    if self.start_date.present?
      if self.end_date.present?
        self.end_date.year - self.start_date.year + ( self.start_date.yday < self.end_date.yday ? 1 : 0 )
      else
        Date.today.year - self.start_date.year + ( self.start_date.yday < Date.today.yday ? 1 : 0 )
      end
    end
  end
  
end
