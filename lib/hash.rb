# Extends the hash object to allow access to items through a dot notation.

class Hash

  def method_missing method, *opts
    if method[-1] == '?'
    then self.include? method[0...-1].to_sym
    else self[method.to_sym] || self[method.to_s]
    end
  end

end
