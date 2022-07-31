require "bunny"
n = 1;

connection = Bunny.new
connection.start

channel = connection.create_channel
# Make sure that the queue will survive a RabbitMQ node restart. 
# In order to do so, we need to declare it as durable.
queue = channel.queue("task_queue", durable: true)

# This tells RabbitMQ not to give more than one message to a worker at a time. 
# In other words don't dispatch a new message to a worker 
# until it has processed and acknowledged the previous one. 
# Instead, it will dispatch it to the next worker that is not still busy.
channel.prefetch(n);

puts ' [*] Waiting for messages. To exit press CTRL+C'

begin
  # using the :manual_ack option and send a proper acknowledgment from the worker, 
  # once we're done with a task.
  queue.subscribe(manual_ack: true, block: true) do |delivery_info, _properties, body|
    puts " [x] Received #{body}"

    sleep body.count('.').to_i
    puts " [x] Done"

    # An ack(nowledgement) is sent back by the consumer to tell RabbitMQ 
    # that a particular message has been received, processed 
    # and that RabbitMQ is free to delete it.
    channel.ack(delivery_info.delivery_tag)
  end
rescue Interrupt => _
  connection.close
end