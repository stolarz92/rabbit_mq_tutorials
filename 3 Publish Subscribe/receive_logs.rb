require "bunny"

connection = Bunny.new
connection.start

channel = connection.create_channel

# The fanout exchange is very simple. As you can probably guess from the name, 
# it just broadcasts all the messages it receives to all the queues it knows. 
exchange = channel.fanout('logs')
# In the Bunny client, when we supply queue name as an empty string, 
# we create a non-durable queue with a generated name:
queue = channel.queue('', exclusive: true)

# That relationship between exchange and a queue is called a binding.
queue.bind(exchange)

puts ' [*] Waiting for logs. To exit press CTRL+C'

begin
  queue.subscribe(block: true) do |_delivery_info, _properties, body|
    puts " [x] #{body}"
  end
rescue Interrupt => _
  channel.close
  connection.close
end