
class Hash
  def delete_blank
    delete_if do |k, v|
      (v.respond_to?(:empty?) ? v.empty? : !v) or v.instance_of?(Hash) && v.delete_blank.empty?
    end
  end
end

class Chef
  class Node
    class ImmutableMash
      def to_hash
        h = {}
        self.each do |k,v|
          if v.respond_to?('to_hash')
            h[k] = v.to_hash
          else
            h[k] = v
          end
        end
        return h
      end
    end
  end
end

module Mongodb3Helper
  def mongodb_config(config)
    config_hash = config.to_hash
    final_hash = config_hash.delete_blank
    JSON.parse(final_hash.dup.to_json).to_yaml
  end
end

module Mongodb3Helper
  def mongodb_config(config)
    config.to_hash.compact.to_yaml
  end
end

class Hash
  def compact
    inject({}) do |new_hash, (k, v)|
      if v.is_a?(Hash)
        v = v.compact
        new_hash[k] = v unless v.empty?
      else
        new_hash[k] = v unless v.nil?
      end
      new_hash
    end
  end
end

