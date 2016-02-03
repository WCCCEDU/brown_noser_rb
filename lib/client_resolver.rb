require 'octokit'

class ClientResolver
  def self.configure(login, password)
    @login = login
    @password = password

    dirty = false
    if @login != login
      dirty = true
      @login = login
    end

    if @password != password
      dirty = true
      @password = password
    end

    if dirty
      @instance = nil
    end
  end

  def self.client
    @instance ||= Octokit::Client.new(:login => @login, :password => @password)
  end
end
