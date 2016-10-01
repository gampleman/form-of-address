class ActiveRecordProxy
  def initialize(target)
    @target = target
  end

  def method_missing(meth)
    value = @target.send(meth)

    if value.is_a?(ActiveRecord::Associations::CollectionProxy)
      value.to_a.map { |item| ActiveRecordProxy.new(item) }
    else
      value
    end
  end
end
