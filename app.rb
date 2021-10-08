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

  name_params = params.slice("C", "ST", "L", "O", "OU", "CN", "emailAddress")
  name_params.delete_if { |k, v| v.nil? || v.strip == ""}
  name_params.transform_values!(&:strip)

  csr.subject = OpenSSL::X509::Name.new(name_params.to_a)
  csr.sign(key, OpenSSL::Digest::SHA256.new)

  uuid = SecureRandom.uuid
  file = Tempfile.open(uuid)

  file << csr.to_pem
  file << key.to_pem
  file.close

  send_file file.path, filename: params["CN"] + ".pem",
    type: "application/x-pem-file"
end
