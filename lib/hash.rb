# Extends the hash object to allow access to items through a dot notation.

class Hash

  def method_missing method, *opts
    method_type = method[-1]

    if method_type == '?'
      self.include? method[0...-1].to_sym
    elsif method_type == '='
      self[ method[0...-1].to_sym ] = opts.first
    else
      self[method] || self[method.to_s]
    end
  end

end
