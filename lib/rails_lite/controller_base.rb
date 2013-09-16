require 'erb'
require_relative 'params'
require_relative 'session'
require 'active_support/core_ext'

class ControllerBase
  attr_reader :params

  def initialize(req, res, route_params)
    @req = req
    @res = res
    @already_built_response = false
    @params = Params.new(req, route_params)
  end

  def session
    @session ||= Session.new(@req)
  end

  def already_rendered?
    @already_built_response
  end

  def redirect_to(url)
    unless already_rendered?
      @res.status = 302
      @res.header["location"] = url
      session.store_session(@res)
      @already_built_response = true
    end
  end

  def render_content(body, content_type)
    unless already_rendered?
      @res.body = body
      @res.content_type = content_type
      session.store_session(@res)
      @already_built_response = true
    end
  end

  def render(template_name)
    template_path = File.join("views", self.class.name.underscore, "#{template_name}.html.erb")
    template = (ERB.new(File.read(template_path))).result(binding)
    render_content(template, "text/html")
  end

  def invoke_action(name)
    self.send(name)
    render(name) unless already_rendered?
  end
end
