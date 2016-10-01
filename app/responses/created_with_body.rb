class CreatedWithBody < Praxis::Response
  self.response_name = :created_with_body
  self.status = 201

  def handle
    headers['Content-Type'] = 'application/json' unless headers['Content-Type']
  end
end
