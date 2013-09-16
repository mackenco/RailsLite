require 'uri'

class Params
  def initialize(req, route_params)
    @params = route_params
    parse_www_encoded_form(req.query_string) if req.query_string
    parse_www_encoded_form(req.body) if req.body
  end

  def [](key)
    @params[key]
  end

  def to_s
    @params.to_json.to_s
  end

  private
  def parse_www_encoded_form(www_encoded_form)
    param_arr = URI.decode_www_form(www_encoded_form)
    param_arr.each do |arr|
      depth = @params

      key_nests = parse_key(arr[0])

      key_nests.each_with_index do |key, i|
        if i + 1 < key_nests.length
          depth[key] ||= {}
          depth = depth[key]
        else
          depth[key] = arr[1]
        end
      end
    end
    @params
  end

  def parse_key(key)
    key.split(/\]\[|\[|\]/)
  end
end
