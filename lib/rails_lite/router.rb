class Route
  attr_reader :pattern, :http_method, :controller_class, :action_name

  def initialize(pattern, http_method, controller_class, action_name)
    @pattern = pattern
    @http_method = http_method
    @controller_class = controller_class
    @action_name = action_name
  end

  def matches?(req)
    (req.request_method.downcase.to_sym == @http_method) && (@pattern =~ req.path)
  end

  def run(req, res)
    params = {}
    match_data = @pattern.match(req.path)
    match_data.names.each do |name|
      params[name] = match_data[name]
    end

    controller = @controller_class.new(req, res, params)
    controller.invoke_action(action_name)
  end
end

class Router
  attr_reader :routes

  def initialize
    @routes = []
  end

  def add_route(pattern, method, controller_class, action_name)
    @routes << Route.new(pattern, method, controller_class, action_name)
  end

  def draw(&proc)
    instance_eval(&proc)
  end

  [:get, :post, :put, :delete].each do |http_method|
    # add these helpers in a loop here
    define_method(http_method) do |pattern, controller_class, action_name|
      add_route(pattern, http_method, controller_class, action_name)
    end
  end

  def match(req)
    match = nil
    routes.each do |route|
      match = route if (route.matches?(req) && match.nil?)
    end
    match
  end

  def run(req, res)
    match = match(req)
    if match.nil?
      res.status == 404
    else
      match.run(req, res)
    end
  end
end
