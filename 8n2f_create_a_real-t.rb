require 'httparty'
require 'json'
require 'websocket-driver'
require 'reactive-ruby'

# Configuration
BLOCKCHAIN_API_KEY = 'YOUR_API_KEY_HERE'
BLOCKCHAIN_API_URL = 'https://api.blockchain.com/v3/'
BLOCKCHAIN_WS_URL = 'wss://ws.blockchain.com/v3/'
DAPP_CONTRACT_ADDRESS = '0x...your_contract_address_here...'

# Websocket connection
ws = WebSocket::Driver.connect(BLOCKCHAIN_WS_URL)

# API request for initial blockchain data
initial_data = HTTParty.get(BLOCKCHAIN_API_URL + 'blockchain')
initial_data = JSON.parse(initial_data.body)

# Set up reactive variables
tx_count = Reactive::Variable.new(0)
block_height = Reactive::Variable.new(initial_data['height'])

# Subscribe to websocket updates
ws.onmessage do |message|
  data = JSON.parse(message.data)
  if data['type'] == 'block'
    block_height << data['height']
  elsif data['type'] == 'transaction'
    tx_count << tx_count.get + 1
  end
end

# Set up dApp tracker
dapp_tracker = {
  'contract_address' => DAPP_CONTRACT_ADDRESS,
  'transactions' => tx_count,
  'block_height' => block_height
}

# Output dApp tracker data in real-time
loop do
  puts "dApp Tracker: #{dapp_tracker.inspect}"
  sleep 1
end