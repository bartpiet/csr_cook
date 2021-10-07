require "sinatra"
require "openssl"
require "tempfile"


get "/" do
  erb :'index.html'
end

post "/" do
  key = OpenSSL::PKey::RSA.new(4096)
  csr = OpenSSL::X509::Request.new
  
  csr.public_key = key.public_key
  csr.subject = OpenSSL::X509::Name.new([
    ["CN", params["cn"]],
    ["emailAddress", params["email"]],
  ])

  uuid = SecureRandom.uuid

  file = Tempfile.new(uuid)

  file << csr.to_pem
  file << key.to_pem
  file.close

  send_file file.path, filename: uuid, type: "application/x-pem-file"
end
