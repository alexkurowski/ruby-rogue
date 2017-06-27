# Extends the hash object to allow access to items through a dot notation.

class Hash

  def method_missing method, *opts
    self[method.to_sym] || self[method.to_s]
  end

end
