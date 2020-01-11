require "rubygems"
require "bundler/setup"
require 'hello_sign'

def initiate_client
    HelloSign::Client.new :api_key => 'YOUR_API_KEYS'
end

def get_total_pages(client)
    list = client.get_signature_requests(page_size: 100)
    list.data["list_info"]["num_pages"]
end

def get_all_requests(client)
    signature_requests = []
    page = 1
    total_pages = get_total_pages(client)

    while page < total_pages + 1
       req = client.get_signature_requests(page_size: 100, page: page)
       signature_requests << req.data["signature_requests"]
       page += 1
    end

    signature_requests.flatten
end

def download_requests(client, requests)
    requests.each do |req|
        begin
            download = client.signature_request_files(
                signature_request_id: req["signature_request_id"],
                file_type: "pdf",
            )

            File.open("downloads/#{req["original_title"]}.pdf", "wb") do |file|
                file.write(download)
            end
        rescue 
            puts "Could not download for id: %%" % req["signature_request_id"]
        end
    end
end

c = initiate_client()
requests = get_all_requests(c)
puts "Downloading %d files" % [requests.length]
download_requests(c, requests)