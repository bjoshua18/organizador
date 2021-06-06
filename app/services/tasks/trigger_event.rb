class Tasks::TriggerEvent
  def call(task, event)
    task.send "#{event}!" # Llamada dinámica
    [true, 'successful']
  rescue => e
    Rails.logger.error e
    [false, 'fail']
  end
end