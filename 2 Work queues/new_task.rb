require "bunny"

connection = Bunny.new
connection.start

channel = connection.create_channel
# Make sure that the queue will survive a RabbitMQ node restart. 
# In order to do so, we need to declare it as durable.
queue = channel.queue("task_queue", durable: true)

message = ARGV.empty? ? "Hello World!" : ARGV.join(' ')

# Mark our messages as persistent by using the :persistent option,
# it tells RabbitMQ to save the message to disk.
queue.publish(message, persistent: true)

puts " [x] Sent #{message}"

connection.close